# Ansible playbook to install TRANA

This is an [Ansible](https://docs.ansible.com/) playbook for installing the
[TRANA](https://github.com/genomic-medicine-sweden/TRANA) pipeline on a
Nanopore instrument.

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
