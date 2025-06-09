# dts-configs

This repository contains config files for boards supported by DTS. The goal is
to replace hard-coded values in the `board_config` function with values parsed
from these files.

## Data structure

Each system vendor (that is being defined by `SYSTEM_VENDOR` variable in DTS)
has a JSON document in the `configs` directory, e.g.:

 ```text
 .
├── configs
│   ├── hardkernel.json
│   ├── notebook.json
│   └── pc_engines.json
└── README.md
 ```

> Note: the system vendor names should be lowercase and with whitespaces
> replaced by `_`.
  
The JSON documents contain variables that are used in DTS and have a specific
structure:

```json
{
  "system_vendor_specific_variable": "value",
  "models": {
    "system_model": {
      "system_model_specific_variable": "value",
      "board_models": {
        "board_model_specific_variable": "value"
      }
    }
  }
}
```

Where:
* First-level keys (the `system_vendor_specific_variable` from the example
above) represent system vendor-specific variables that are common for system
models and board models.
* Second-level keys (the `system_model_specific_variable` from the example
above) represent system model-specific variables that are common for system
models and board models under specific system vendor.
* Third-level keys (the `board_model_specific_variable` from the example above)
represent board model-specific variables that are common for a specific board
model under specific system model.

The variables set at a higher levels could be overwritten on lower levels. All
the variables **must be** lowercase and should be present in the list of
variables below:

```text
dasharo_rel_name
dasharo_rel_ver
dasharo_rel_ver_dpp
dasharo_rel_ver_dpp_cap
heads_rel_ver_dpp
dasharo_rel_ver_dpp_seabios
compatible_ec_fw_version
compatible_heads_ec_fw_version
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
flash_chip_list
flashrom_add_opt_deploy
flashrom_add_opt_update
bucket_dpp
bucket_dpp_heads
can_use_flashrom
```

Not all system models are divided into board models, sometimes the
`board_models` dictionary migth be absent in the JSON files.

## Example changes

Bumping the firmware revision for an existing board (`Odroid H4+`):

```diff
diff --git a/configs/hardkernel.json b/configs/hardkernel.json
index f4c7e96..8607095 100644
--- a/configs/hardkernel.json
+++ b/configs/hardkernel.json
@@ -6,7 +6,7 @@
       "platform_sign_key": "dasharo/hardkernel_odroid_h4/dasharo-release-0.x-compatible-with-hardkernel-odroid-h4-family-signing-key.asc",
       "bucket_dpp": "dasharo-odroid-h4-plus-uefi",
       "dasharo_rel_name": "hardkernel_odroid_h4",
-      "dasharo_rel_ver_dpp": "0.9.0"
+      "dasharo_rel_ver_dpp": "0.9.1"
     }
   }
 }
```

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
