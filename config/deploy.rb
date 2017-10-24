require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
# require 'mina/rvm'    # for rvm support. (https://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application_name, 'foobar'
set :domain, 'root@39.108.232.49' #服务器地址,是使用ssh的方式登录服务器
set :deploy_to, '/home/deploy/ggl' #服务器中项目部署位置
set :repository, 'https://github.com/jx-bamboo/ggl.git' #git代码仓库
set :branch, 'master' #git分支

# 中括号里的文件 会出现在服务器项目附录的shared文件夹中，这里加入了secrets.yml，环境密钥无需跟开发计算机一样
#set :shared_paths, ['config/database.yml', 'log', 'config/secrets.yml']


# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# set :shared_dirs, fetch(:shared_dirs, []).push('somedir')
set :shared_dirs,['tmp','log','uploads']
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.

# 这个块里面的代码表示运行 mina setup时运行的命令
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', 'ruby-1.9.3-p125@default'

  # 在服务器项目目录的shared中创建log文件夹
  command %[mkdir -p "#{fetch(:deploy_to)}/shared/log"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/log"]

  # 在服务器项目目录的shared中创建config文件夹 下同
  command %[mkdir -p "#{fetch(:deploy_to)}/shared/config"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/config"]

  command %[touch "#{fetch(:deploy_to)}/shared/config/database.yml"]
  command %[touch "#{fetch(:deploy_to)}/shared/config/secrets.yml"]

  # puma.rb 配置puma必须得文件夹及文件
  command %[mkdir -p "#{fetch(:deploy_to)}/shared/tmp/pids"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/tmp/pids"]

  command %[mkdir -p "#{fetch(:deploy_to)}/shared/tmp/sockets"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/tmp/sockets"]

  command %[touch "#{fetch(:deploy_to)}/shared/config/puma.rb"]
  command  %[echo "-----> Be sure to edit 'shared/config/puma.rb'."]

  # tmp/sockets/puma.state
  command %[touch "#{fetch(:deploy_to)}/shared/tmp/sockets/puma.state"]
  command  %[echo "-----> Be sure to edit 'shared/tmp/sockets/puma.state'."]

  # log/puma.stdout.log
  command %[touch "#{fetch(:deploy_to)}/shared/log/puma.stdout.log"]
  command  %[echo "-----> Be sure to edit 'shared/log/puma.stdout.log'."]

  # log/puma.stdout.log
  command %[touch "#{fetch(:deploy_to)}/shared/log/puma.stderr.log"]
  command  %[echo "-----> Be sure to edit 'shared/log/puma.stderr.log'."]

  command  %[echo "-----> Be sure to edit '#{fetch(:deploy_to)}/shared/config/database.yml'."]
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0}
end

#这个代码块表示运行 mina deploy时执行的命令
desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.

    #重新拉git服务器上的最新版本，即使没有改变
    invoke :'git:clone'
    #重新设定shared_path位置
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        #command %{mkdir -p tmp/}
        #command %{touch tmp/restart.txt}
        command "mkdir -p #{fetch(:deploy_to)}/#{current_path}/tmp/"
        command "touch #{fetch(:deploy_to)}/#{current_path}/tmp/restart.txt"
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
