# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# This is a configuration based Vagrantfile
# You can use this to create a single vm that will pull in your local projects
# You can extend that to run multiple containers per project
# Each project can have as many provisioners, just make sure the paths are relative to this dir.
#
#################################################################
require 'getoptlong'
require 'yaml'

# Custom option added to allow config file to be set by the caller.
# This allows us to build different vms for the tests.
# @todo GetoptLong should not throw errors for unknown options, right now it does
#       For now, this means that we need to define each vagrant option that we use.
opts        = GetoptLong.new(
    [ '--config', GetoptLong::OPTIONAL_ARGUMENT ],
    [ '--provision', GetoptLong::OPTIONAL_ARGUMENT ]
)
config_file = 'vagrant.yml'
opts.each do |opt, arg|
  case opt
    when '--config'
      config_file=arg
  end
end

# Yaml doesn't convert to symbols, this will force it.
def symbolize(obj)
    return obj.inject({}){|memo,(k,v)| memo[k.to_sym] =  symbolize(v); memo} if obj.is_a? Hash
    return obj.inject([]){|memo,v    | memo           << symbolize(v); memo} if obj.is_a? Array
    return obj
end

# Yaml, people like it and it's easy to comment in.
user_config = {}
user_config = YAML.load_file(config_file) if File.file?(config_file)
user_config = symbolize(user_config)

Vagrant.configure(2) do |vagrant_config|
    vagrant_config.ssh.insert_key = false
    vagrant_config.vm.box         = user_config[:host][:box] if user_config[:host][:box]
    vagrant_config.disksize.size  = user_config[:host][:root_size] if user_config[:host][:root_size]

    vagrant_config.vm.provider "virtualbox" do |v|
        v.cpus      = user_config[:host][:cpus] if user_config[:host][:cpus]
        v.memory    = user_config[:host][:ram] if user_config[:host][:ram]
    end

    vagrant_config.vm.network "private_network", ip: user_config[:host][:ip]

    # Each project can mount as many dirs as they would like.
    user_config[:host][:mount_dirs].each{|mount_config|
        mount_config[:create]   = mount_config[:create] || true
        if mount_config[:local] && mount_config[:remote]
            puts "[host]::[mount]::[host-to-vagrant]::[#{mount_config[:local]}]::[#{mount_config[:remote]}]"
            vagrant_config.vm.synced_folder mount_config[:local], mount_config[:remote], **mount_config
        end
    } if user_config[:host][:mount_dirs]

    user_config[:projects].each {|project|
        puts "[VAGRANT CONFIG]+++++++++++++++++++++++++++++++"
        puts "[#{project[:name]}]::[host]::[#{user_config[:host][:ip]} #{project[:host_name]}]"

        # Each project can mount as many dirs as they would like.
        project[:mount_dirs].each{|mount_config|
            mount_config[:create]   = mount_config[:create] || true
            if mount_config[:local] && mount_config[:remote]
                puts "[#{project[:name]}]::[mount]::[host-to-vagrant]::[#{mount_config[:local]}]::[#{mount_config[:remote]}]"
                vagrant_config.vm.synced_folder mount_config[:local], mount_config[:remote], **mount_config
            end
        } if project[:mount_dirs]

        # Afford each project as many provisioning scripts as the user want's to define.
        project[:provision].each{|provisioner_type, provisioner_type_config|
            provisioner_type_config.each{|provisioner_config|
                puts "[#{project[:name]}]::[provision]::[#{provisioner_type}]::[#{provisioner_config}]"
                vagrant_config.vm.provision provisioner_type, **provisioner_config
            } if provisioner_type_config
        } if project[:provision]

        # Expose your ports from local guest to host.
        project[:ports].each {|port_config|
            puts "[#{project[:name]}]::[port]::[#{port_config[:guest]}:#{port_config[:host]}]::[#{port_config[:protocol]}]"
            vagrant_config.vm.network "forwarded_port", **port_config
        } if project[:ports]

        # Support docker they ask? Support docker we do.
        if project[:docker]
            vagrant_config.vm.provision "docker" do |d|

                # pull in any vendor images.
                project[:docker][:pull_images].each {|image_config|
                    puts "[#{project[:name]}]::[docker]::[pull]::[#{image_config[:name]}]"
                    d.pull_images image_config[:name]
                } if project[:docker][:pull_images]

                # Build a custom image from a provided docker file path.
                # Auto set the image name if not passed in the args.
                project[:docker][:build].each {|build_config|
                    puts "[#{project[:name]}]::[docker]::[build]::[#{build_config[:name]}]"
                    build_config[:args] = build_config[:args] || ""
                    set_tag     = build_config[:args] =~ /-t/i
                    build_config[:args].concat(" -t #{build_config[:name]}") if set_tag.nil?
                    d.build_image build_config[:dockerfile_remote_path], **build_config
                } if project[:docker][:build]

                # Auto set the container name and host if not passed in the args.
                project[:docker][:run].each {|run_config|
                    puts "[#{project[:name]}]::[docker]::[run]::[#{run_config[:name]}.#{project[:host_name]}]"
                    run_config[:args] = run_config[:args] || ""
                    set_name    = run_config[:args] =~ /--name/i
                    set_host    = run_config[:args] =~ /-h/i
                    run_config[:args].concat(" --name #{run_config[:name]}") if set_name.nil?
                    run_config[:args].concat(" -h #{run_config[:name]}.#{project[:host_name]}") if set_host.nil?

                    # allow us to mount from vagrant to container
                    # this supports the idea of "live" coding.
                    run_config[:mount_dirs].each{|mount_config|
                        if mount_config[:local] && mount_config[:remote]
                            puts "[#{project[:name]}]::[mount]::[vagrant-to-container]::[#{mount_config[:local]}]::[#{mount_config[:remote]}]"
                            run_config[:args].concat(" -v #{mount_config[:local]}:#{mount_config[:remote]}")
                        end
                    } if run_config[:mount_dirs]

                    d.run run_config[:name], **run_config
                } if project[:docker][:run]
            end
        end

        # Support docker compose plugin
        # @link https://github.com/leighmcculloch/vagrant-docker-compose
        # @dep  vagrant plugin install vagrant-docker-compose
        if project[:docker_compose]
            puts "[#{project[:name]}]::[docker_compose]::[provision]::#{project[:docker_compose][:yml]}"
            compose_config = project[:docker_compose]
            vagrant_config.vm.provision :docker_compose, **project[:docker_compose]
        end


        puts "[#{project[:name]}]::[project configured]::[#{project[:host_name]}]"
        puts "++++++++++++++++++++++++++++++++++++++++++++++"
    } if user_config[:projects]
end