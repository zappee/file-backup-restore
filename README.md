## 🐧 File Backup & Restore

![GitHub top language](https://img.shields.io/github/languages/top/zappee/file-backup-restore)
![GitHub Issues](https://img.shields.io/github/issues/zappee/file-backup-restore)
![GitHub Release](https://img.shields.io/github/v/release/zappee/file-backup-restore)

### 1) Overview

A simple, secure, and interactive file copy and backup tool to back up and restore files especially for laptops.
If you use external USB hard drives or flash drives to back up your personal files, documents, and photos, this tool makes the process effortless.
It is specifically built for people who need to manage backups of multiple different laptops or computers and keep the files synced between the laptops.

It handles adding, deleting, and renaming files and directories seamlessly.
It also works perfectly when tracking changes to file properties, such as modification timestamps, ownership, permissions, and system flags.

Unlike other automated tools that run silently in the background, this tool uses a two-step confirmation process.
It shows you a "preview" of exactly what files will be copied, changed, or deleted before it actually modifies anything on your disks, giving you complete control and peace of mind.


### 2) Why Use This Tool?

* **Safe execution:** Automatically runs a dry-run first to visualize differences (additions, modifications, deletions) before executing the actual sync.
* **Smart disk space management:** Offers three ways to handle your backups: save everything (`keep`), clean up old files before copying (`delete-before`), or clean up files as it goes (`delete-during`).
* **Output explainer:** Embedded documentation within the script breaks down complex rsync shortcodes.
* **Built for multiple computers:** You can easily create custom configuration files for your work laptop, personal laptop, or family computers, keeping all your backup routines organized in one place.
* **Visual progress:** Displays clear progress bars and file sizes while copying so you never have to guess if the backup is frozen.


### 3) What's inside the box?

* `sync-engine.sh`: The core execution engine containing script arguments validation, double-prompt safeguards, and the main rsync orchestration logic. You don't need to change this file.
* `sync-task-backup-hp.sh`: A configuration script illustrating how to back up local folders to your external hard drive.
* `sync-task-restore-hp.sh`: A corresponding profile showing how to quickly reverse the flow to copy your files back from your external drive to your laptop (perfect for setting up a new computer or recovering from a crash).


### 4) Prerequisites

* Ensure you are using a Unix-like environment with `rsync` installed.
* Check if rsync is available: `rsync --version`


### 5) Engine Script Usage

The core engine script `sync-engine.sh` handles individual directory copies directly:

```console
$ ./sync-engine.sh <source-directory> <target-directory> [mode]
```

**Arguments:**
* `source-directory`: The folder containing the files you want to back up.
* `target-directory`: The target destination disk or folder for your backups.
* `mode` (optional): Decides how target-only files are handled:
    * `keep` (default): Never delete files from the backup directory.
    * `delete-before`: Deletes removed files from the backup disk *before* transferring new files (ideal for low-capacity target drives).
    * `delete-during`: Deletes removed files from the backup disk step-by-step *while* the transfer runs.

**Example:**
```console
$ ./sync-engine.sh ~/workspace /media/usb-drive/backup-hdd1/ delete-before
```


### 6) How to use it

Instead of passing arguments manually every time, you can maintain clean profiles for your personal devices using wrapper files like the provided templates.

#### 6.1) Configure a machine to back up
Copy the backup template file (`sync-task-backup-hp.sh`) to customize it for your specific machine (`sync-task-backup-hp-spectre.sh`) and edit your paths:

```console
SOURCE_HOME=/home/$USER/Workspace
TARGET_HOME=/media/$USER/USB-Disk/hdd-1
```

Specify the directories you would like to back up:
```console
do_backup "1/3" projects delete-during
do_backup "2/3" documents delete-during
do_backup "3/3" software-installers keep
```

#### 6.2) Configure a machine to restore
Copy the restore template file (`sync-task-restore-hp.sh`) to customize it for your specific machine (`sync-task-restore-hp-spectre.sh`) and reverse your paths:

```console
SOURCE_HOME=/media/$USER/USB-Disk/hdd-1
TARGET_HOME=/home/$USER/Workspace

do_backup "1/2" projects delete-during
do_backup "2/2" documents delete-during
```


### 7) How it works

When you start a backup or recovery job, the tool stops and asks for your input twice to protect your data from accidental loss:

1. **Dry-run analysis:** The script simulates the task without altering data.
2. **First prompt:** It displays the raw upcoming changes and pauses:
   `Comparing the SOURCE and TARGET directories and show the difference. Continue? [y/n]`
3. **Second prompt:** If you approve, it flashes a final warning before writing files to the destination medium:
   `Do you want to copy files from SOURCE to TARGET?`
   `Files on TARGET media will be overwritten!`
   `Continue [y/n]`


### 8) Understanding `rsync` outputs

When the comparison table scrolls past during Step 1, you can read the structural shortcodes (`YXcstpoguax`) using this reference pattern:

* **First character (`Y`):** The action type, e.g., `>` file received, `<` file sent, `c` local creation, `.` metadata-only change.
* **Second character (`X`):** The item type, `f` for file, `d` for directory, `L` for symlink.
* **Attributes (`cstpoguax`):** Identifies property updates where `s` indicates a modified file size, `t` flags a timestamp update, and `p` warns of permission variations.


### 🤝 Contributing

Contributions, feature requests, optimization, and bug reports are always welcome!
For more information, please visit my [homepage](https://zappee.github.io).
