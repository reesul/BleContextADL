from datetime import timedelta
import statistics


class BLELogProcessorJyotish(object):
    def __init__(self, ble_log):
        self.delta = timedelta(seconds=4)  # if it is 10, it misses some MAC
        self.ble_log = ble_log

        every_macs = ble_log.all_mac_addr
        self.scan_list = self.get_scan_time_list(self.delta)
        # self.every_mac_in_scan_list = [emisl for vv in self.scan_list.values() for emisl in vv]

        self.support_data = self.get_support_data(every_macs)
        self.good_set = GoodSet(self.scan_list, self.support_data, every_macs)
        self.similarity_graph = SimilarityGraph(self.scan_list, self.good_set.get_good_set(), every_macs)

        # vv, ee = self.similarity_graph.get_graph_data()
        # print(vv)
        # print(ee)

    def get_support_data(self, all_mac_addr):
        s_list = self.scan_list
        mac_all = all_mac_addr
        mac_count_data = MacCountData(mac_all, s_list)
        mac_support_data = MacSupportData(mac_count_data)

        return mac_support_data

    def get_scan_time_list(self, delta):
        time_list = dict()  # scan time: BT MAC address
        devices = self.ble_log.get_device_list()
        start_time = self.ble_log.scan_start_time
        limit = self.ble_log.scan_end_time
        scan_time = start_time
        t_threshold = delta.total_seconds()

        while scan_time < limit:
            macs = []
            for dev in devices:
                timeslot = dev.timeslot

                for t in timeslot:
                    t_diff = t - scan_time
                    duration = t_diff.total_seconds()
                    if abs(duration) <= t_threshold:
                        macs.append(dev.mac)
                        break

            if len(macs) != 0:
                time_list.update({scan_time: macs})
            scan_time = scan_time + delta

        return time_list


class GoodSet(object):
    def __init__(self, scan_list, macs_support_values, every_mac):
        self.distribution = []
        self.good_set = []  # ∆
        good_set_mac = []  # ∆_A

        for scan_time, macs_list in scan_list.items():
            dd = DataDistribution(scan_time, macs_list, macs_support_values)
            self.distribution.append(dd)
            #  print('{} = {}'.format(scan_time, dd.get_coeff_of_var()))

        ordered_distribution = sorted(self.distribution)

        for ordered_d in ordered_distribution:
            key = ordered_d.time_slot
            mac_values = scan_list[key]
            how_many_added = 0
            for mac_candidates in mac_values:
                if mac_candidates not in good_set_mac:
                    how_many_added += 1
                    good_set_mac.append(mac_candidates)

            if how_many_added > 0:
                self.good_set.append(ordered_d) # change what to add

            set_size = len(every_mac)
            if len(good_set_mac) == set_size:
                break

    def get_distribution(self):
        return self.distribution

    def get_increment_order_list(self):
        return sorted(self.distribution)

    def get_good_set(self):
        return self.good_set


class SimilarityGraph(object):
    def __init__(self, scan_list, good_set_list, mac_all):
        threshold = 0.25  # change this value to see other graphs
        self.vertex = []  # put time slots
        self.edges = []

        self.bit_vectors = BitVectors(scan_list, good_set_list, mac_all).get_bit_vectors()
        tc = TanimotoCoeff(self.bit_vectors)
        degree = dict()  # time : degree of graph

        for index, gs0 in enumerate(good_set_list):  # set vertex, edges, degree
            time_slot0 = gs0.time_slot
            self.vertex.append(time_slot0)
            if time_slot0 not in degree:
                degree.update({time_slot0: 0})

            for gs1 in good_set_list[index + 1:]:
                time_slot1 = gs1.time_slot
                coeff = tc.get_coeff_in(time_slot0, time_slot1)
                if coeff > threshold:  # then, an edge exists
                    self.edges.append(tuple((time_slot0, time_slot1)))
                    degree[time_slot0] += 1

                    if time_slot1 not in degree:
                        degree.update({time_slot1: 1})
                    else:
                        degree[time_slot1] += 1

        # check Handshaking lemma
        assert sum(degree.values()) == 2 * len(self.edges)

        # Star Clustering to get Candidate Cluster Set
        vertex_size = len(self.vertex)
        high_degrees = sorted(degree, key=degree.get, reverse=True)
        high_degree_time = high_degrees[0]
        candidate_cluster_centers = []
        marked_nodes = []

        while len(marked_nodes) < vertex_size:
            for h in high_degrees:
                if h not in marked_nodes:
                    marked_nodes.append(h)
                    candidate_cluster_centers.append(h)
                    high_degree_time = h
                    break
            # connected_nodes = [node for node in self.edges if high_degree_time in node]
            connected_nodes = []
            for edge in self.edges:
                if high_degree_time in edge:
                    n0, n1 = edge
                    if n0 == high_degree_time:
                        connected_nodes.append(n1)
                    else:
                        connected_nodes.append(n0)

            marked_nodes.extend(connected_nodes)

        # Get Final Cluster Set
        # First, get each signature vectors
        signature_vectors = dict()
        for c0 in candidate_cluster_centers:
            s_vec = self.bit_or(self.bit_vectors[c0], self.bit_vectors[c0])
            for edge in self.edges:
                if c0 in edge:
                    c1 = edge[0]
                    if c1 == c0:
                        c1 = edge[1]
                    s_vec = self.bit_or(s_vec, self.bit_vectors[c1])

            signature_vectors.update({c0: s_vec})

        # Merge step

        time_list_dict = dict()
        merged_clusters = dict()
        for time_key, vec in signature_vectors.items():
            time_list_dict.update({time_key: sum(vec.values())})
        time_list_reverse_order = sorted(time_list_dict, key=time_list_dict.get, reverse=True)

        for index, c0 in enumerate(time_list_reverse_order):
            merging = []
            m_cluster_keys = list(merged_clusters.keys())
            m_cluster_values = list(merged_clusters.values())
            if c0 not in m_cluster_keys and all(c0 not in mcv for mcv in m_cluster_values):
                for c1 in time_list_reverse_order[index + 1:]:
                    if c1 not in m_cluster_keys and all(c1 not in mcv for mcv in m_cluster_values):
                        target = self.bit_or(signature_vectors[c0], signature_vectors[c1])
                        if target == signature_vectors[c0]:
                            merging.append(c1)

                if len(merging) != 0:
                    merged_clusters.update({c0: merging})

        self.cluster_centers = dict([(kk, []) for kk in candidate_cluster_centers])
        if merged_clusters:
            update_list = list(merged_clusters.keys())
            for time_update in update_list:
                vals = merged_clusters[time_update]
                self.cluster_centers.update({time_update: vals})
                for vv in vals:
                    self.cluster_centers.pop(vv, None)

    def bit_or(self, vector0, vector1):
        ret = dict()
        for time_key in vector0:
            or_value = 1
            if vector0[time_key] == 0 and vector1[time_key] == 0:
                or_value = 0
            ret.update({time_key: or_value})
        return ret

    def get_graph_data(self):
        return self.vertex, self.edges

    def get_cluster_centers(self):
        return self.cluster_centers


class TanimotoCoeff(object):
    def __init__(self, bv):
        self.coeff = dict()
        times = list(bv.keys())

        for index, t0 in enumerate(times):
            for t1 in times[index + 1:]:
                size_t0 = self.get_custom_dot_product(bv[t0], bv[t0])
                size_t1 = self.get_custom_dot_product(bv[t1], bv[t1])

                dot_t0_t1 = self.get_custom_dot_product(bv[t0], bv[t1])

                coeff = dot_t0_t1 / (size_t0 + size_t1 - dot_t0_t1)

                self.coeff.update({self.get_custom_key_name(t0, t1):coeff})

    def get_custom_key_name(self, t0, t1):
        return '{}-{}'.format(t0, t1)

    def get_custom_dot_product(self, bv0, bv1):
        vec_size = len(bv0)
        if vec_size != len(bv1):
            assert False

        ret = 0
        for time_slot in bv0:
            if bv0[time_slot] == 1 and bv1[time_slot] == 1:
                ret += 1

        return ret

    def get_coeff(self):
        return self.coeff

    def get_coeff_in(self, t0, t1):
        key = self.get_custom_key_name(t0, t1)

        if key not in self.coeff.keys():
            key = self.get_custom_key_name(t1, t0)

        return self.coeff[key]


class BitVectors(object):
    def __init__(self, scan_list, good_set_list, mac_all):
        self.bit_vectors = dict()  # time_slot : binary 1010 vec dict, size of total MACs
        vec_size = len(mac_all)

        for gs in good_set_list:
            vec = dict(zip(mac_all, [0] * vec_size))
            time_slot = gs.time_slot
            macs_list = scan_list[time_slot]
            for mac in macs_list:
                vec[mac] = 1

            self.bit_vectors.update({time_slot: vec})

    def get_bit_vectors(self):
        return self.bit_vectors


class DataDistribution(object):
    def __init__(self, time_slot, mac_list_in_scan, mac_support_data):
        self.time_slot = time_slot
        self.mean = 1.0
        self.sd = 0.0  # standard deviation
        self.cv = 0.0  # coefficient of variation

        if len(mac_list_in_scan) != 1:
            support_values = []
            for index, m0 in enumerate(mac_list_in_scan):
                for m1 in mac_list_in_scan[index + 1:]:
                    support_values.append(mac_support_data.get_support_value(m0, m1))

            self.mean = statistics.mean(support_values)
            if len(support_values) > 1:
                self.sd = statistics.stdev(support_values)
            self.cv = self.sd / self.mean

    def __lt__(self, other):
        return self.cv < other.cv  # and self.time_slot < other.time_slot

    def __le__(self, other):
        return self.cv <= other.cv

    def __gt__(self, other):
        return self.cv > other.cv

    def __ge__(self, other):
        return self.cv >= other.cv

    '''def __eq__(self, other):
        return self.cv == other.cv

    def __ne__(self, other):
        return self.cv != other.cv'''

    def get_coeff_of_var(self):
        return self.cv


class CountData(object):
    def __init__(self):
        self.count = 0
        self.timelist = []

    def add_time(self, time_slot):
        self.count += 1
        self.timelist.append(time_slot)

    def get_data(self):
        return self.count, self.timelist


class MacCountData(object):
    def __init__(self, mac_all, scan_list):
        val = []
        for v in mac_all:
            val.append(CountData())
        self.count_data = dict(zip(mac_all, val))  # mac address: count, time list

        for time_stamp, macs in scan_list.items():
            for mac_addr in mac_all:
                if mac_addr in macs:
                    self.count_data[mac_addr].add_time(time_stamp)

    def get_data(self, mac_addr):
        return self.count_data[mac_addr].get_data()


class MacSupportData(object):
    def __init__(self, mac_count_data):
        self.delim = '-'
        self.support = dict()  # mac0-mac1 key: support counts

        macs = list(mac_count_data.count_data.keys())
        # mac_count_data.count_data,  dict - key (mac address): CountData
        for index, mac0 in enumerate(macs):
            count_mac0, time_slot_mac0 = mac_count_data.get_data(mac0)

            for mac1 in macs[index + 1:]:
                count_mac1, time_slot_mac1 = mac_count_data.get_data(mac1)
                assert(count_mac0 != 0 and count_mac1 != 0)
                denominator = min([count_mac0, count_mac1])
                count = 0

                for t in time_slot_mac0:
                    if t in time_slot_mac1:
                        count += 1

                self.support.update({self.mac_concat(mac0, mac1): count / denominator})

    def mac_concat(self, m0, m1):
        return "{}{}{}".format(m0, self.delim, m1)

    def get_support_value(self, m0, m1):
        key = self.mac_concat(m0, m1)
        if key not in self.support.keys():
            key = self.mac_concat(m1, m0)

        if key not in self.support.keys():
            assert (key in self.support.keys())

        return self.support[key]


if __name__ == "__main__":
    from datetime import datetime
    fp = open('MacCase1.txt', 'r')
    line = fp.readline()
    mac_test = []
    mac_counter = 0
    while line:
        line = line.replace(' ', '')  # remove spaces
        line = line.replace('{', '')
        line = line.replace('}', '')
        line = line.replace('\n', '')
        line = line.replace('\r', '')

        line = line.split(',')
        if line[0]:
            for item_line in line:
                if line.count(item_line) != 1:  # check duplicates in line
                    assert False
            mac_test.append(line)
            mac_counter += 1
        line = fp.readline()

    fp.close()

    date_start = '08/27/18 08:42:57'
    time_delta = timedelta(seconds=5)
    datetime_start = datetime.strptime(date_start, '%m/%d/%y %H:%M:%S')
    dt = datetime_start

    date_list = []
    macs_all = []

    for mc in mac_test:
        for mmm in mc:
            if mmm not in macs_all:
                macs_all.append(mmm)

        date_list.append(dt)
        dt = dt + time_delta

    value = mac_test
    scan__list = dict(zip(date_list, value))
    md = MacCountData(macs_all, scan__list)
    for mm in macs_all:
        print(md.get_data(mm))
    macs_support_d = MacSupportData(md)

    for k, v in macs_support_d.support.items():
        print('{}: {}'.format(k, v))

    # test get_support_value method
    # print(mac_support_data.get_support_value(mac_all[0], mac_all[3]))
    # print(mac_support_data.get_support_value(mac_all[3], mac_all[4]))

    gooS = GoodSet(scan__list, macs_support_d, macs_all)
    sg = SimilarityGraph(scan__list, gooS.get_good_set(), macs_all)

    # v, e = sg.get_graph_data()
    # print(v)
    # print(e)

    centers = sg.get_cluster_centers()
    for cs in centers:
        t_ind = 1 + (cs - datetime_start).total_seconds() / time_delta.total_seconds()
        print('{}; {}'.format(t_ind, scan__list[cs]))


