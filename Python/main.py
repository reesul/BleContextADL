def main():
    from my_data import BLELog
    from processing import BLELogProcessorJyotish

    path = '/Users/minku/OneDrive - Texas A&M University/ESP/Projects/BLE Localization/Data/'
    '''sub_dir = ['08-27-18', '08-28-18', '08-29-18', '08-30-18', '08-31-18',
               '09-16-18', '09-17-18']'''
    sub_dir = ['08-27-18']
    file_name = '/ble_data.txt'

    for sd in sub_dir:
        name = path + sd + file_name
        ble_log = BLELog(name)
        logProcessed = BLELogProcessorJyotish(ble_log)

        centers = logProcessed.similarity_graph.get_cluster_centers()
        for cs in centers:
            print('{}; {}'.format(cs, logProcessed.scan_list[cs]))

        print(len(centers))


def test():
    from datetime import datetime, timedelta

    # List Comprehensions in Python
    # [ expression for item in list if conditional ]
    '''== for item in list:
    if conditional:
        expression'''
    dd = {'key1': ["value1", "value2"],
          'key2': ["value77", "something"],
          'k': ['Henry', '777', 'Value77'],
          'kk': ['Hi', 'value77', 'zer0'],
          'k0': ['value777', 'value77']
          }
    all_v = dd.values()
    ll = [x for v in all_v for x in v]
    tt = "value77" in ll and 'zer0' in ll
    print(all_v)
    print(ll)
    print(tt)
    print(ll.count('value77'))
    t0 = timedelta(seconds=10)
    t1 = timedelta(seconds=5)

    t2 = t0 - t1
    t3 = t1 - t0

    print(t2.total_seconds())
    print(t3.total_seconds())

if __name__ == "__main__":
    # test()
    main()
