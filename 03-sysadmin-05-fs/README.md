# Домашнее задание к занятию "3.5. Файловые системы"


### Инструменты/ дополнительные материалы, которые пригодятся для выполнения задания

1. Разряженные файлы - [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB)
2. [Подробный анализ производительности RAID,3-19 страницы](https://www.baarf.dk/BAARF/0.Millsap1996.08.21-VLDB.pdf).
3. [RAID5 write hole](https://www.intel.com/content/www/us/en/support/articles/000057368/memory-and-storage.html).


1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.
    
    <details>
    <summary>Ответ</summary>

        Разрежённый файл (англ. sparse file) — файл, в котором последовательности нулевых байтов заменены на информацию об этих последовательностях (список дыр).
        Дыра (англ. hole) — последовательность нулевых байт внутри файла, не записанная на диск. Информация о дырах (смещение от начала файла в байтах и количество байт) хранится в метаданных ФС.
        
        Преимущества:
        •   экономия дискового пространства. Использование разрежённых файлов считается одним из способов сжатия данных на уровне файловой системы;
        •   отсутствие временных затрат на запись нулевых байт;
        •   увеличение срока службы запоминающих устройств.

        Недостатки:
        •   накладные расходы на работу со списком дыр;
        •   фрагментация файла при частой записи данных в дыры;
        •   невозможность записи данных в дыры при отсутствии свободного места на диске;
        •   невозможность использования других индикаторов дыр, кроме нулевых байт.
        
        создание разрежённого файла размером 200 Гб:
        dd if=/dev/zero of=./sparse-file bs=1 count=0 seek=200G
            или
        truncate -s200G ./sparse-file
        
        преобразование обычного файла в разрежённый (выполнение поиска дыр и записи их расположения (смещений и длин) в метаданные файла):
        cp --sparse=always ./simple-file ./sparse-file

        сохранение копии диска в разрежённый файл утилитой ddrescue:
        ddrescue --sparse /dev/sdb ./sparse-file ./history.log
        
    </details>
    
2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?
    
    <details>
    <summary>Ответ</summary>

        Нет. Файлы, являющиеся жесткой ссылкой на один объект, не могут иметь разные права доступа и владельца, т.к. hard link имеет тот же номер inode на который ссылается. А inode хранит в себе:
        •   Идентификатор владельца
        •   Идентификатор группы
        •   Разрешения на чтение, запись и выполнение

    </details>
    
3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```

    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.
    
    <details>
    <summary>Ответ</summary>

        ВМ запущена успешно

    </details>
    
4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.
    
    <details>
    <summary>Ответ</summary>

        Вижу два добавленных диска:
        ```bash
        # fdisk -l
        Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
        Disk model: VBOX HARDDISK
        Units: sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        
        Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
        Disk model: VBOX HARDDISK
        Units: sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        ```

        ```bash
        # fdisk /dev/sdb
        Command (m for help): n
        Partition type
        p   primary (0 primary, 0 extended, 4 free)
        e   extended (container for logical partitions)
        Select (default p): p
        Partition number (1-4, default 1): 1
        First sector (2048-5242879, default 2048):
        Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G
        
        Created a new partition 1 of type 'Linux' and of size 2 GiB.
        
        Command (m for help): w
        The partition table has been altered.
        Calling ioctl() to re-read partition table.
        Syncing disks.
        ```
        
        Получился раздел на 2 Gb:
        ```bash
        # fdisk -l
        ...
        Device     Boot Start     End Sectors Size Id Type
        /dev/sdb1        2048 4196351 4194304   2G 83 Linux
        ...
        ```
        
        Затем распределим оставшиеся 500 Мб
        ```bash
        # fdisk /dev/sdb
        Command (m for help): p
        Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
        Disk model: VBOX HARDDISK
        Units: sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disklabel type: dos
        Disk identifier: 0x0eae18a0
        
        Device     Boot Start     End Sectors Size Id Type
        /dev/sdb1        2048 4196351 4194304   2G 83 Linux
        
        Command (m for help): n
        Partition type
        p   primary (1 primary, 0 extended, 3 free)
        e   extended (container for logical partitions)
        Select (default p): p
        Partition number (2-4, default 2): 4
        First sector (4196352-5242879, default 4196352):
        Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879):
        
        Created a new partition 4 of type 'Linux' and of size 511 MiB.
        
        Command (m for help): p
        Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
        Disk model: VBOX HARDDISK
        Units: sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disklabel type: dos
        Disk identifier: 0x0eae18a0
        
        Device     Boot   Start     End Sectors  Size Id Type
        /dev/sdb1          2048 4196351 4194304    2G 83 Linux
        /dev/sdb4       4196352 5242879 1046528  511M 83 Linux
        
        Command (m for help): w
        The partition table has been altered.
        Calling ioctl() to re-read partition table.
        Syncing disks.
        ```

        ```bash
        # fdisk -l
        ...
        Device     Boot   Start     End Sectors  Size Id Type
        /dev/sdb1          2048 4196351 4194304    2G 83 Linux
        /dev/sdb4       4196352 5242879 1046528  511M 83 Linux
        ...
        ```

    </details>
    
5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.
    
    <details>
    <summary>Ответ</summary>

        Просмотр таблицы разделов:
        ```bash
        # sfdisk -l /dev/sdb
        Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
        Disk model: VBOX HARDDISK
        Units: sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disklabel type: dos
        Disk identifier: 0x0eae18a0
        
        Device     Boot Start     End Sectors Size Id Type
        /dev/sdb1        2048 4196351 4194304   2G 83 Linux
        ```
        
        Создадим копию данных о разделах со старого диска:
        ```bash
        # sfdisk -d /dev/sdb > partitions-sda.txt
        ```

        Теперь запишем эту таблицу на новый диск:
        ```bash
        # sfdisk /dev/sdc < partitions-sda.txt
        Checking that no-one is using this disk right now ... OK
        
        Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
        Disk model: VBOX HARDDISK
        Units: sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        
        >>> Script header accepted.
        >>> Script header accepted.
        >>> Script header accepted.
        >>> Script header accepted.
        >>> Created a new DOS disklabel with disk identifier 0x0eae18a0.
        /dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
        /dev/sdc2: Done.
        
        New situation:
        Disklabel type: dos
        Disk identifier: 0x0eae18a0
        
        Device     Boot Start     End Sectors Size Id Type
        /dev/sdc1        2048 4196351 4194304   2G 83 Linux
        
        The partition table has been altered.
        Calling ioctl() to re-read partition table.
        Syncing disks.
        ```
        
        
        Просмотр таблици разделов до переноса таблици разделов на диск /dev/sdc
        ```bash
        # sfdisk -l /dev/sdc
        Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
        Disk model: VBOX HARDDISK
        Units: sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        ```
        
        
        Просмотр таблици разделов после переноса таблици разделов на диск /dev/sdc
        ```bash
        # sfdisk -l /dev/sdc
        Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
        Disk model: VBOX HARDDISK
        Units: sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disklabel type: dos
        Disk identifier: 0x0eae18a0
        
        Device     Boot Start     End Sectors Size Id Type
        /dev/sdc1        2048 4196351 4194304   2G 83 Linux
        ```

    </details>
    
6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.
    
    <details>
    <summary>Ответ</summary>

        ```bash
        # fdisk -l
        Device     Boot   Start     End Sectors  Size Id Type
        /dev/sdb1          2048 4196351 4194304    2G 83 Linux
        /dev/sdb2       4196352 5242879 1046528  511M 83 Linux
        ...
        Device     Boot   Start     End Sectors  Size Id Type
        /dev/sdc1          2048 4196351 4194304    2G 83 Linux
        /dev/sdc2       4196352 5242879 1046528  511M 83 Linux
        ```

        Сначала необходимо занулить суперблоки на дисках, которые мы будем использовать для построения RAID (если диски ранее использовались, их суперблоки могут содержать служебную информацию о других RAID):

        ```bash
        mdadm --zero-superblock --force /dev/sdb1
        mdadm --zero-superblock --force /dev/sdc1
        ```

        Далее нужно удалить старые метаданные и подпись на дисках:
        ```bash
        wipefs --all --force /dev/sdb1
        wipefs --all --force /dev/sdc1
        ```

        Для сборки избыточного массива применяем следующую команду:

        ```bash
        # mdadm --create --verbose /dev/md1 -l 1 -n 2 /dev/sdb1 /dev/sdc1
        mdadm: Note: this array has metadata at the start and
        may not be suitable as a boot device.  If you plan to
        store '/boot' on this device please ensure that
        your boot-loader understands md/v1.x metadata, or use
        --metadata=0.90
        mdadm: size set to 2094080K
        Continue creating array? y
        mdadm: Defaulting to version 1.2 metadata
        mdadm: array /dev/md1 started.
        ```

        * где:
            /dev/md1 — устройство RAID, которое появится после сборки; 
            -l 1 — уровень RAID; 
            -n 2 — количество дисков, из которых собирается массив; 
            /dev/sdb1 /dev/sdc1 — сборка выполняется из дисков sdb1 и sdc1.
        
        Вводим команду:
        ```bash
        # lsblk
        NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
        loop0                       7:0    0   62M  1 loop  /snap/core20/1611
        loop2                       7:2    0 67.8M  1 loop  /snap/lxd/22753
        loop3                       7:3    0 49.9M  1 loop  /snap/snapd/18596
        loop4                       7:4    0 63.3M  1 loop  /snap/core20/1852
        loop5                       7:5    0 91.9M  1 loop  /snap/lxd/24061
        sda                         8:0    0   64G  0 disk  
        ├─sda1                      8:1    0    1M  0 part  
        ├─sda2                      8:2    0    2G  0 part  /boot
        └─sda3                      8:3    0   62G  0 part  
          └─ubuntu--vg-ubuntu--lv 253:0    0   31G  0 lvm   /
        sdb                         8:16   0  2.5G  0 disk  
        ├─sdb1                      8:17   0    2G  0 part  
        │ └─md1                     9:1    0    2G  0 raid1 
        └─sdb2                      8:18   0  511M  0 part  
        sdc                         8:32   0  2.5G  0 disk  
        ├─sdc1                      8:33   0    2G  0 part  
        │ └─md1                     9:1    0    2G  0 raid1 
        └─sdc2                      8:34   0  511M  0 part  
        ```

        В файле mdadm.conf находится информация о RAID-массивах и компонентах, которые в них входят. Для его создания выполняем следующие команды:
        ```bash
        echo "DEVICE partitions" >> /etc/mdadm/mdadm.conf
        mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
        ```

        Пример содержимого:
        ```bash
        DEVICE partitions
        ARRAY /dev/md1 level=raid1 num-devices=2 metadata=1.2 name=vagrant:1 UUID=7d0a48c9:9cfec310:a6900eab:663f24d6
        ```
        * хранится информация о массиве /dev/md1 — его уровень 1, он собирается из 2-х дисков.


        Создание файловой системы для массива выполняется также, как для раздела, например:
        ```bash
        mkfs.xfs /dev/md1
        ```

        Примонтировать раздел можно командой:
        ```bash
        mkdir /mnt_raid1
        mount /dev/md1 /mnt_raid1
        ```
        * примонтировали наш массив в каталог /mnt_raid1.

        ```bash
        # df -h
        Filesystem                         Size  Used Avail Use% Mounted on
        ...
        /dev/md1                           2.0G   47M  2.0G   3% /mnt_raid1
        ```

        Чтобы данный раздел также монтировался при загрузке системы, добавляем в fstab.
        Сначала смотрим идентификатор раздела:
        ```bash
        # blkid
        ...
        /dev/md1: UUID="e2c07d76-7260-40e9-91ee-a0cc1f465e4f" TYPE="xfs"
        ```

        Открываем теперь fstab и добавляем строку:
        ```bash
        vi /etc/fstab
        UUID="e2c07d76-7260-40e9-91ee-a0cc1f465e4f"    /mnt_raid1    xfs    defaults    0 0
        ```

    </details>
    
7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.
    
    <details>
    <summary>Ответ</summary>

        ```bash
        # fdisk -l
        Device     Boot   Start     End Sectors  Size Id Type
        /dev/sdb1          2048 4196351 4194304    2G 83 Linux
        /dev/sdb2       4196352 5242879 1046528  511M 83 Linux
        ...
        Device     Boot   Start     End Sectors  Size Id Type
        /dev/sdc1          2048 4196351 4194304    2G 83 Linux
        /dev/sdc2       4196352 5242879 1046528  511M 83 Linux
        ```

        Подготовка носителей
        Сначала необходимо занулить суперблоки на дисках, которые мы будем использовать для построения RAID (если диски ранее использовались, их суперблоки могут содержать служебную информацию о других RAID):
        ```bash
        mdadm --zero-superblock --force /dev/sdb2
        mdadm --zero-superblock --force /dev/sdc2
        ```

        Если мы получили ответ:
        
        mdadm: Unrecognised md component device - /dev/sd*
        то значит, что диски не использовались ранее для RAID. Просто продолжаем настройку.
        
        
        Далее нужно удалить старые метаданные и подпись на дисках:
        ```bash
        wipefs --all --force /dev/sdb2
        wipefs --all --force /dev/sdc2
        ```
        
            Создание рейда
        Для сборки избыточного массива применяем следующую команду:
        
        ```bash
        mdadm --create --verbose /dev/md0 -l 0 -n 2 /dev/sdb2 /dev/sdc2
        ```

        * где:
        /dev/md0 — устройство RAID, которое появится после сборки; 
        -l 0 — уровень RAID; 
        -n 2 — количество дисков, из которых собирается массив; 
        /dev/sdb2 /dev/sdc2 — сборка выполняется из дисков sdb2 и sdc2.
        
        ```bash
        # mdadm --create --verbose /dev/md0 -l 0 -n 2 /dev/sdb2 /dev/sdc2
        mdadm: chunk size defaults to 512K
        mdadm: Defaulting to version 1.2 metadata
        mdadm: array /dev/md0 started.
        ```
        
        Вводим команду:
        ```bash
        # lsblk
        NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
        loop0                       7:0    0   62M  1 loop  /snap/core20/1611
        loop2                       7:2    0 67.8M  1 loop  /snap/lxd/22753
        loop3                       7:3    0 49.9M  1 loop  /snap/snapd/18596
        loop4                       7:4    0 63.3M  1 loop  /snap/core20/1852
        loop5                       7:5    0 91.9M  1 loop  /snap/lxd/24061
        sda                         8:0    0   64G  0 disk  
        ├─sda1                      8:1    0    1M  0 part  
        ├─sda2                      8:2    0    2G  0 part  /boot
        └─sda3                      8:3    0   62G  0 part  
          └─ubuntu--vg-ubuntu--lv 253:0    0   31G  0 lvm   /
        sdb                         8:16   0  2.5G  0 disk  
        ├─sdb1                      8:17   0    2G  0 part  
        │ └─md1                     9:1    0    2G  0 raid1 /mnt_raid1
        └─sdb2                      8:18   0  511M  0 part  
          └─md0                     9:0    0 1018M  0 raid0 
        sdc                         8:32   0  2.5G  0 disk  
        ├─sdc1                      8:33   0    2G  0 part  
        │ └─md1                     9:1    0    2G  0 raid1 /mnt_raid1
        └─sdc2                      8:34   0  511M  0 part  
          └─md0                     9:0    0 1018M  0 raid0 
        ```
        
        
            Создание файла mdadm.conf
        В файле mdadm.conf находится информация о RAID-массивах и компонентах, которые в них входят. Для его создания выполняем следующие команды:
        ```bash
        echo "DEVICE partitions" >> /etc/mdadm/mdadm.conf
        mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
        ```

        Пример содержимого:
        ```bash
        DEVICE partitions
        ARRAY /dev/md0 level=raid0 num-devices=2 metadata=1.2 name=vagrant:0 UUID=3642eba0:09aa1fd3:555b8607:21a5e52f
        ```

        * в данном примере хранится информация о массиве /dev/md0 — его уровень 0, он собирается из 2-х дисков.
        
        
            Создание файловой системы и монтирование массива
        Создание файловой системы для массива выполняется также, как для раздела, например:
        
        ```bash
        mkfs.xfs /dev/md0
        ```
        
        Примонтировать раздел можно командой:
        ```bash
        mkdir /mnt_raid0
        mount /dev/md0 /mnt_raid0
        ```
        * в данном случае мы примонтировали наш массив в каталог /mnt_raid1.
        
        ```bash
        # df -h
        Filesystem                         Size  Used Avail Use% Mounted on
        ...
        /dev/md0                          1013M   40M  973M   4% /mnt_raid0
        ```
        
        Чтобы данный раздел также монтировался при загрузке системы, добавляем в fstab.
        Сначала смотрим идентификатор раздела:
        ```bash
        # blkid
        ...
        /dev/md0: UUID="7e8c4d83-77b7-485b-b6b2-80faf9399444" TYPE="xfs"
        ```
        
        Открываем теперь fstab и добавляем строку:
        ```bash
        vi /etc/fstab
        UUID="7e8c4d83-77b7-485b-b6b2-80faf9399444"    /mnt_raid0    xfs    defaults    0 0
        ```

    </details>
    
8. Создайте 2 независимых PV на получившихся md-устройствах.
    
    <details>
    <summary>Ответ</summary>

        ololololololololololololololololololololol

    </details>
    
9. Создайте общую volume-group на этих двух PV.
    
    <details>
    <summary>Ответ</summary>

        ololololololololololololololololololololol

    </details>
    
10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.
    
    <details>
    <summary>Ответ</summary>

        ololololololololololololololololololololol

    </details>
    
11. Создайте `mkfs.ext4` ФС на получившемся LV.
    
    <details>
    <summary>Ответ</summary>

        ololololololololololololololololololololol

    </details>
    
12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.
    
    <details>
    <summary>Ответ</summary>

        ololololololololololololololololololololol

    </details>
    
13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.
    
    <details>
    <summary>Ответ</summary>

        ololololololololololololololololololololol

    </details>
    
14. Прикрепите вывод `lsblk`.
    
    <details>
    <summary>Ответ</summary>

        ololololololololololololololololololololol

    </details>
    
15. Протестируйте целостность файла:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```
    
    <details>
    <summary>Ответ</summary>

        ololololololololololololololololololololol

    </details>
    
16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.
    
    <details>
    <summary>Ответ</summary>

        ololololololololololololololololololololol

    </details>
    
17. Сделайте `--fail` на устройство в вашем RAID1 md.
    
    <details>
    <summary>Ответ</summary>

        ololololololololololololololololololololol

    </details>
    
18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.
    
    <details>
    <summary>Ответ</summary>

        ololololololololololololololololololololol

    </details>
    
19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```
    
    <details>
    <summary>Ответ</summary>

        ololololololololololololololololololololol

    </details>
    
20. Погасите тестовый хост, `vagrant destroy`.
    
    <details>
    <summary>Ответ</summary>

        ВМ удалена успешно

    </details>
    

---

## Как сдавать задания

Обязательными к выполнению являются задачи без указания звездочки. Их выполнение необходимо для получения зачета и диплома о профессиональной переподготовке.

Задачи со звездочкой (*) являются дополнительными задачами и/или задачами повышенной сложности. Они не являются обязательными к выполнению, но помогут вам глубже понять тему.

Домашнее задание выполните в файле readme.md в github репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

Также вы можете выполнить задание в [Google Docs](https://docs.google.com/document/u/0/?tgif=d) и отправить в личном кабинете на проверку ссылку на ваш документ.
Название файла Google Docs должно содержать номер лекции и фамилию студента. Пример названия: "1.1. Введение в DevOps — Сусанна Алиева".

Если необходимо прикрепить дополнительные ссылки, просто добавьте их в свой Google Docs.

Перед тем как выслать ссылку, убедитесь, что ее содержимое не является приватным (открыто на комментирование всем, у кого есть ссылка), иначе преподаватель не сможет проверить работу. Чтобы это проверить, откройте ссылку в браузере в режиме инкогнито.

[Как предоставить доступ к файлам и папкам на Google Диске](https://support.google.com/docs/answer/2494822?hl=ru&co=GENIE.Platform%3DDesktop)

[Как запустить chrome в режиме инкогнито ](https://support.google.com/chrome/answer/95464?co=GENIE.Platform%3DDesktop&hl=ru)

[Как запустить  Safari в режиме инкогнито ](https://support.apple.com/ru-ru/guide/safari/ibrw1069/mac)

Любые вопросы по решению задач задавайте в чате Slack.

---