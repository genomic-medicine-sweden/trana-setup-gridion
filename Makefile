install:
	# Run the Ansible Playbook locally
	ansible-playbook --connection=local --inventory=127.0.0.1 playbook.yml

install-sudo:
	# Run the Ansible Playbook locally
	ansible-playbook --connection=local --inventory=127.0.0.1 --ask-become-pass playbook.yml
