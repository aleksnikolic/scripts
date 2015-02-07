#!/usr/bin/python
import sys,os
from optparse import OptionParser
from virtinst.util import *
if sys.version_info < (2,5):
        import lxml.etree as ET
else:
        import xml.etree.ElementTree as ET
 
 
parser = OptionParser();
parser.add_option("-n", "--name", dest="name",
        help="VM name");
parser.add_option("-c", "--config", dest="config",
        help="Template VM XML config file");
 
(options, args) = parser.parse_args();
 
if not options.name or not options.config:
        print "Usage %s -n name -c template_xml" % sys.argv[0]
        sys.exit(1)
 
config = ET.parse(options.config)
vm_name = options.name
name = config.find('name')
name.text = vm_name
uuid = config.find('uuid')
uuid.text = uuidToString(randomUUID())
mac = config.find('devices/interface/mac')
mac.attrib['address'] = randomMAC(type='qemu')
disk = config.find('devices/disk/source')
disk_old = disk.attrib['file']
disk_path = os.path.dirname(disk_old)
disk_ext = os.path.splitext(disk_old)[1]
disk_image = disk_path + '/' + vm_name + disk_ext
disk.attrib['file'] = disk_image
 
if os.path.exists(vm_name + '.xml'):
        print "File %s.xml exists, abort" % vm_name
        sys.exit(1)
config.write(vm_name + '.xml')
print "Created vm config file %s.xml" % vm_name
print "Use disk image %s, you must create it from the template disk: %s" % (disk_image, disk_old)
print "Done!"
