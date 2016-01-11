First, edit inventory to point to `base` and `targets`. Secondly, if 
ansible is already installed:

```bash
ansible-galaxy install angstwad/docker_ubuntu
ansible-playbook \
  -i inventory \
  -b \
  --extra-vars \
    '{ "benchmarks": ["ivotron/comd","ivotron/redisbench"]}'
  playbook.yml
```

In docker:

```
docker build ansible-port .
docker run ansible-port
```

Dependencies:

  * docker 1.7+ on localhost
  * Ubuntu 12.04+ on remote nodes

