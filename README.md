# process-ph3
The evolution of a process: phase 3

In phase 1, a small app was baked-in to a Docker container. In phase 2, an AMI was built to support that container in AWS. In this phase [Terraform] will deploy the container to an AWS Instance spun-up from that AMI.

Pull the code and move into the process-ph3 directory:
```bash
git clone git@github.com:todd-dsm/process-ph3.git && cd process-ph3/
```

There are a lot of files in here but only a few are important. Everything is supportive:

* `test_systems.sh`: a convenience wrapper to speed builds, removes, cleaning up statefiles, etc.
* `actuate.tf`: the main terraform file; draws from:
 * `outputs.tf`: a file to define elements output from the build
 * `vars.tf`: a variables definition file.

***
The terraform job is designed to be run by either:

* A 'sysadmin': with an ssh key defined as: `~/.ssh/id_rsa.pub`, or
* A process, like [Jenkins]: with an ssh key defined as `~/.ssh/builder.pub`

It's also intended to pull the proper AMI based on the deployment `region`. This has become unnecessary as `actuate.tf` now has `data "aws_ami" "base_ami"`; this accomplishes the same requirement, and cleaner, but `variable "AMIS"` was left in to demonstrate conditions can be imposed within Terraform; i.e.:

IF there were AMIs in variant regions AND the region was changed, Terraform would pull the correct AMI for that region.

The automation for this step is currently incomplete. The Docker container had issues when I found it. It can be spun-up but it's really just incorrect. This container is currently being replaced. **Check back soon**.

However, to see the Terraform job in action - minus the container - call `test_systems.sh` with the `-b` option:

`./test_systems.sh -b`

There is a lot of output; this is for Jenkins logging and traceability. The main gist is that there are steps for a Terraform `validate` and `plan` built-in before the `apply` step; each has the opportunity to fail a build before running a job in AWS that will cost money and ultimately not work.

At the end, the remote system's IP address is saved to `/tmp/rhost.tfout` for consumption of Ansible, Puppet or Chef. The defined outputs are printed to stdOut.

A `terraform show | grep 'image_id'` shows that the latest AMI was pulled to build the instance.

To inspect the Instance, login with the output `ip`; example:
`ssh admin@52.11.112.251`

Check this instance for configurations imposed during Phase 2, like:

```bash
cat /etc/build-info 
Build date/time: 20170222-144430
```
When done with the inspection, log out of the instance:

```bash
admin@52.11.112.251:~$ exit
logout
Connection to 52.11.112.251 closed.
myHost:process-ph3 user$ 
```

The instance can be destroyed easily when you're finally done:

`./test_systems.sh --destroy`

So there are no lingering state files lying about, clean them up as well:

`./test_systems.sh --cleanup`

For now, that's all there is in Phase 3. Check back periodically; currently updating this repo.

***

## Review
This is all well and good but, we're still dragging the habits of the old data center into the modern cloud. To remedy that, check back to see Phase 4, a.k.a. - **Deploying an Instance with a _modern_ approach**. 

This approach will decrease complexity, increase security, and make (normally) complex deployments easier than you might think. Stay tuned...


[Terraform]:https://www.terraform.io/
[Jenkins]:https://jenkins.io/