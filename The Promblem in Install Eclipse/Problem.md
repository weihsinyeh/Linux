### Step 1
Go to Eclipse Website download "eclipse-inst-jre-linux64.tar.gz"

Then Go to Downloads  ```cd Downloads```

Then ```tar -xf eclipse-inst-jre-linux64.tar.gz```

```cd eclipse-installer```

complie
```./eclipse-inst```

### Promblem 1
(SWT:3323): GLib-GObject-WARNING **: 21:09:46.918: cannot register existing type 'GtkIMContext'

(SWT:3323): GLib-CRITICAL **: 21:09:46.918: g_once_init_leave: assertion 'result != 0' failed

(SWT:3323): GLib-GObject-CRITICAL **: 21:09:46.918: g_type_register_dynamic: assertion 'parent_type > 0' failed

(SWT:3323): GLib-GObject-CRITICAL **: 21:09:46.918: g_object_new_with_properties: assertion 'G_TYPE_IS_OBJECT (object_type)' failed

### Solve 1

Reference : https://bugs.eclipse.org/bugs/show_bug.cgi?id=442741#c3
This problem is a duplicate of bug 430736. root cause of the problem is due to older glibc version. in gtk3 we need glibc to be at least 2.14. but the machine where the problem is reported has 2.13.

There are 2 ways to fix this

1. upgrade glibc version to 2.14 (lot of other tools also require 2.14 and we recommend this)
2. use gtk2 for eclipse

you can make eclipse to use GTK2 in the following ways

1. add the following lines to eclipse.ini before -vmargs(recommended approach)
--launcher.GTK_version
2

2. set the environment variable SWT_GTK3 to 0 before launching eclipse. you need to do this every time you launch eclipse

### REFERENCE: https://stackoverflow.com/questions/35616650/how-to-upgrade-glibc-from-version-2-12-to-2-14-on-centos
#### Then I download glibc-2.14.tar.gz
```tar -xf glibc-2.14.tar.gz```
but make -j4 cannot run

