# Ansible playbook to install TRANA

This is an [Ansible](https://docs.ansible.com/) playbook for installing the
[TRANA](https://github.com/genomic-medicine-sweden/TRANA) pipeline (which
includes the [EMU tool](https://github.com/treangenlab/emu)) on a Nanopore
GridIon X5 instrument with a single command.

In addition to TRANA and EMU

- The [TranaVy reporting tool](https://github.com/kclinmicro/TranaVy)
- Automation scripts for detecting and starting TRANA when a 16S sequencing is
  finished.
- Scripts for running the TranaVy reporting tool on outputs from TRANA.

## Structure

The script sets up a folder structure under `/data/trana` that looks like this:

```bash
/data/
  trana/
    16s-report/     # Home of the TranaVy tool
    barcodesheets/  # Barcodesheets to map ONT barcodes to sample IDs
    bin/            # Folder for executable files
    install/        # This is not created by the script, but is the suggested
                    # place to clone this repo
    output/         # Here outputs from pipeline runs are placed
    run/            # Folder for the run scripts and some log files generated
    trana/          # Installation folder for the TRANA pipeline
    work/           # Nextflow work folder
```

In the `run` folder, there is a script `detect-data-and-run.sh` that looks for
folders named `/data/16s_ont_<any_string_here>` for which it will wait until
the sequencing is done, and then start the TRANA run on that data.

This script needs to be run either manually or set up with `cron` to be run on
a given schedule.

## Dependencies

You will need to have Ansible installed for this to work.
You can install it on Debian and Ubuntu-based Linux systems with:

```bash
sudo apt install ansible
```

## Usage

To install TRANA on a GridIon, or comparabla compter, do the following:

### Create a trana + install folder and enter it

```bash
mkdir -p /data/trana/install
```

### Clone the repository into /data/trana/install

(Don't miss the dot in the end of the git command)

```bash
cd /data/trana/install
git clone https://github.com/genomic-medicine-sweden/trana-setup-gridion.git .
```

### Run the ansible script via make

```bash
make install
```

### What to expect?

When this is finished, you should see the folder structure mentioned above.

### Extra steps

The script does not set up the cron scripts required to run the script that
checks if any sequencing runs are finished. Instead, this has to be set up
manually.

This can be done by running `crontab -e` as the `grid` user, and add a line
there running e.g. every 5 minutes, that executes the script:
```bash
/data/trana/run/detect-data-and-run.sh
```

It can look like this:
```crontab
*/5 * * * * bash /data/trana/run/detect-data-and-run.sh
```
