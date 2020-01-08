Vagrant Compose
===============

Description
-----------
* Composable Vagrant tool to build from YAML file. 
* This project was created to build vagrant VM's based on a YAML configuration file; with the basic goal to make it flexible for day to day use and provide a consistent and easy to manage configuration.
* There's support for a single VM, multiple VM's, Docker, Docker Compose and bash provisioning.  

State
-----
This project has been slowly created over the past few years; finally releasing it now that I'm not really using it too much. 

How Use This Project 
--------------------
* To use this project, download the release and save the ```Vagrantfile``` and ```vagrant.yml``` in the root of your project. 
* Open up the YAML configuration file and update it to define your project needs. 

Use Vagrant
-----------
Download and install [virtuablox](https://www.virtualbox.org/wiki/Downloads) and [vagrant](https://www.virtualbox.org/wiki/Downloads).

```commandline
vagrant up 
vagrant ssh 
vagrant halt 
vagrant reload 
vagrant reoload --provision 
vagrant provision 
vagrant destroy
```

Configure Vagrant
-----------------
By default, Vagrant is looking for a file named ```vagrant.yml``` in the root of your project. The full options of the config file are documented in ```example-config/documented.yml```, please reference there if you need more information.

#### To use another YAML file for the config you can define it when you execute Vagrant commands.   
```bash
vagrant --config=vagrant-example.yml up
```

#### To use docker-compose in Vagrant this plugin is required.
- [plugin repo](https://github.com/leighmcculloch/vagrant-docker-compose)
```
vagrant plugin install vagrant-docker-compose
```

#### To set root_size in vagrant.yml:host, this plugin is required.
- [plugin repo](https://github.com/sprotheroe/vagrant-disksize)
```commandline
vagrant plugin install vagrant-disksize
```


Links
-----
* [virtualbox](https://www.virtualbox.org/wiki/Downloads)
* [vagrant](https://www.vagrantup.com/downloads.html)
* [Vagrant Docs](https://www.vagrantup.com/docs)
