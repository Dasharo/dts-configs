# dts-configs

This repository contains config files for boards supported by DTS. The goal is
to replace hard-coded values in the `board_config` function with values parsed
from these files.

## Data structure

Each board vendor (defined as the lowercase value of `SYSTEM_VENDOR` in DTS.
Replace any whitespaces with `_`.) has a JSON document in the `boards`
directory, which contains variables used in DTS (`board_config` function).
Top-level key-value pairs correspond to variables that are common for all boards
from the vendor. The `models` key contains a list of board models (output of
`SYSTEM_MODEL`) with key-value pairs corresponding to model-specific variables. 

It is important to note that some boards can have the same `SYSTEM_MODEL`, but
different values of `BOARD_MODEL` in DTS. For example, the system model
`V54x_6x_TU` has 2 board models: `V540TU` and `V560TU`. In such cases, an
additional field `board_model` needs to be added to the system model dictionary.
See examples for more details.

## Making changes

### Modifying existing boards

Make changes to the board dictionary in the vendor JSON.

### Adding a new board

1. If the vendor JSON already exists, add the board to the `models` dictionary.
It should be a nested dictionary.
2. If the vendor JSON does not exist, create it.
3. Fill out model-specific variables.

List of keys that are used as variables in DTS:

```text
dasharo_rel_name
dasharo_rel_ver
dasharo_rel_ver_dpp
dasharo_rel_ver_dpp_cap
heads_rel_ver_dpp
dasharo_rel_ver_dpp_seabios
compatible_ec_fw_version
dasharo_rel_ver_cap
dasharo_rel_ver_dpp_cap
dasharo_support_cap_from
can_install_bios
have_heads_fw
have_ec
need_ec_reset
need_smbios_migration
need_smmstore_migration
need_bootsplash_migration
need_blob_transmission
need_romhole_migration
programmer_bios
programmer_ec
flashrom_add_opt_update_override
heads_switch_flashrom_opt_override
platform_sign_key
```

Some platforms have additional variables that are not present here. Check
`dts-scripts` for more information.

### Examples

Adding new boards with separate `BOARD_MODEL` (Novacustom `V54x_6x_TU`):

```diff
diff --git a/configs/notebook.json b/configs/notebook.json
index 1e357a0..e61816d 100644
--- a/configs/notebook.json
+++ b/configs/notebook.json
@@ -12,6 +12,29 @@
       "heads_rel_ver_dpp": "0.9.1",
       "heads_switch_flashrom_opt_override": "--ifd -i bios",
       "compatible_ec_fw_version": "2022-08-31_cbff21b"
+    },
+    "V54x_6x_TU": {
+      "dasharo_rel_ver": "0.9.0",
+      "compatible_ec_fw_version": "2024-07-17_4ae73b9",
+      "need_bootsplash_migration": "true",
+      "board_models": {
+        "V540TU": {
+          "dasharo_rel_name": "novacustom_v54x_mtl",
+          "flashrom_add_opt_update_override": "--ifd -i bios",
+          "have_heads_fw": true,
+          "heads_rel_ver_dpp": "0.9.0",
+          "compatible_heads_ec_fw_version": "2024-07-17_4ae73b9",
+          "heads_switch_flashrom_opt_override": "--ifd -i bios"
+        },
+        "V560TU":{
+          "dasharo_rel_name": "novacustom_v56x_mtl",
+          "flashrom_add_opt_update_override": "--ifd -i bios",
+          "have_heads_fw": true,
+          "heads_rel_ver_dpp": "0.9.0",
+          "compatible_heads_ec_fw_version": "2024-12-20_368e08e",
+          "heads_switch_flashrom_opt_override": "--ifd -i bios"
+        }
+      }
     }
   }
 }
```

Adding a new vendor (MSI `MS-7D25`):

```diff
diff --git a/configs/micro-star_international_co.,_ltd.json b/configs/micro-star_international_co.,_ltd.json
new file mode 100644
index 0000000..c5acffc
--- /dev/null
+++ b/configs/micro-star_international_co.,_ltd.json
@@ -0,0 +1,21 @@
+{
+  "bucket_dpp": "dasharo-msi-uefi",
+  "bucket_dpp_heads": "dasharo-msi-heads",
+  "models": {
+    "MS-7D25": {
+      "dasharo_rel_name": "msi_ms7d25",
+      "dasharo_rel_ver": "1.1.1",
+      "dasharo_rel_ver_dpp": "1.1.4",
+      "can_install_bios": true,
+      "have_heads_fw": true,
+      "heads_rel_ver_dpp": "0.9.0",
+      "heads_switch_flashrom_opt_override": "--ifd -i bios",
+      "platform_sign_key": "dasharo/msi_ms7d25/dasharo-release-1.x-compatible-with-msi-ms-7d25-signing-key.asc dasharo/msi_ms7d25/dasharo-release-0.x-compatible-with-msi-ms-7d25-signing-key.asc",
+      "need_smbios_migration": true,
+      "need_smmstore_migration": true,
+      "need_romhole_migration": true,
+      "need_bootsplash_migration": "true",
+      "flashrom_add_opt_update_override": "--ifd -i bios"
+    }
+  }
+}
