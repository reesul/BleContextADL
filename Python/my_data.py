from datetime import datetime


class BLELog(object):
    def __init__(self, file_name):
        f = open(file_name, 'r')
        lines = f.readlines()

        # MAC 75:AB:6A:68:CD:03, etc duplicated
        self.scanner_id = lines.pop(0).rstrip()  # BLE scanner(watch, etc) ID
        self.ble_list = []

        starting_time = []
        ending_time = []
        self.all_mac_addr = []
        for line in lines:
            d = Device(line)
            check_mac = d.mac in self.all_mac_addr
            if not check_mac:
                self.ble_list.append(d)
                self.all_mac_addr.append(d.mac)
            else:  # ignored multiple raw packets
                # test_i = self.all_mac_addr.index(d.mac)
                # print(test_i)
                dev = self.get_device_by_mac(d.mac)
                dev.timeslot.extend(d.timeslot)
                dev.rssis.extend(d.rssis)

            starting_time.append(d.timeslot[0])
            ending_time.append(d.timeslot[-1])

        self.scan_start_time = min(starting_time)
        self.scan_end_time = max(ending_time)

        f.close()

    def get_device_list(self):
        return self.ble_list

    def get_device_by_mac(self, mac_addr):
        ret = None
        b_list = self.ble_list

        for b in b_list:
            if mac_addr in b.mac:
                ret = b
                break

        return ret

class Device(object):
    def __init__(self, line):  # change input to file name later
        line = line.strip().split(',')

        self.timeslot, self.date = self.parse_timeslot(line[0])
        self.mac = self.do_single_parse(line[1])
        self.name = self.do_single_parse(line[2])
        rssi_string = self.do_multi_parse(line[3])
        self.raw_data = self.do_single_parse(line[4])

        # change to int list
        self.rssis = [int(r) for r in rssi_string]

    '''def calculate_active_duration(self):
        total_len = len(self.timeslot)
        if total_len == 1:  # the beacon existed too short
            return 1

        ret = 0
        start_time = self.timeslot[0]
        end_time = self.timeslot[-1]
        duration = end_time - start_time
        delta = (self.timeslot[1] - start_time).total_seconds()

        if delta * (total_len - 1) == duration:
            ret = duration.total_seconds()

        return ret'''

    def parse_timeslot(self, textline):  # return datetime format values
        time = []
        parse = self.do_multi_parse(textline)
        recorded_date = parse[0].split(' ')[0]

        # timeslot = map(lambda foo: foo.replace(recorded_date + ' ', ''), timeslot)
        for p in parse:
            temp = datetime.strptime(p, '%m/%d/%y %H:%M:%S')
            time.append(temp)

        date = datetime.strptime(recorded_date, '%m/%d/%y')

        return time, date

    def do_single_parse(self, text):
        t0 = text.split(':{')
        ret = t0[1][:-1]  # remove end }

        return ret

    def do_multi_parse(self, text):
        t0 = text.split(':{')
        t0.pop(0)  # remove front part
        content = t0[0][:-1]  # remove end }
        t1 = content.split(';')

        return t1
