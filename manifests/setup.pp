#init -> packages -> user -> setup -> install -> config -> service  
 class gitlab::setup inherits gitlab {
   
  #Install bundler gem
  package { 'bundler':
    ensure    => installed,
    provider  => gem,
  }
  
  package { 'mysql2' :
    ensure    => '0.3.11',
    provider  => gem,
  }
  
  #Install charlock_holmes 
  package { 'charlock_holmes':
    ensure    => '0.6.9.4',
    provider  => 'gem',
    require   => [
                  Package['bundler'],
                  Package['mysql2'],
                  ],
  }
  
  notify { "Installing charlock holmes with ruby version ${::rubyversion}" : 
  }
  
  #Execute all commands as the git user in the git home directory
  Exec {
    user    => "${gitlab::git_user}",
    cwd     => "${gitlab::git_home}",
    path    => '/usr/bin',
  }
  
  #Download gitlab-shell (replaces git-o-lite)
  exec { 'download gitlab-shell':
    command   => "git clone ${gitlab::gitlabshell_sources} ${gitlab::git_home}/gitlab-shell",
    creates   => "${gitlab::git_home}/gitlab-shell",
  }
  
  #Download gitlab source
  exec { 'download gitlab':
    command => "git clone -b ${gitlab::gitlab_branch} ${gitlab::gitlab_sources} ${gitlab::git_home}/gitlab",
    creates   => "${gitlab::git_home}/gitlab",
  }
  
  
  #Copy the gitlab-shell config
  file { "${gitlab::git_home}/gitlab-shell/config.yml":
    ensure    => file,
    content   => template('gitlab/gitlab-shell.erb'),
    owner     => "${gitlab::git_user}",
    group     => 'git',
    require   => [
                  Exec['download gitlab-shell'],
                  Exec['download gitlab'],
                  ]
  }
  
  
  #Copy the gitlab config
  file { "${gitlab::git_home}/gitlab/config/gitlab.yml":
    ensure    => file,
    content   => template('gitlab/gitlab.yml.6-0.erb'),
    owner     => "${gitlab::git_user}",
    group     => 'git',  
    require   => [
                  Exec['download gitlab-shell'],
                  Exec['download gitlab'],
                  ]
  }
  
  #Copy the Unicorn config
  file { "${gitlab::git_home}/gitlab/config/unicorn.rb":
    ensure    => file,
    content   => template('gitlab/unicorn.rb.6-0-stable.erb'),
    owner     => "${gitlab::git_user}",
    group     => 'git',
    require   => [
                  Exec['download gitlab-shell'],
                  Exec['download gitlab'],
                  ]
  }
  
  #Copy the database config
  file { "${gitlab::git_home}/gitlab/config/database.yml":
    ensure    => file,
    content   => template('gitlab/database.yml.erb'),
    owner     => "${gitlab::git_user}",
    group     => 'git',
    mode      => '0640',
    require   => [
                  Exec['download gitlab-shell'],
                  Exec['download gitlab'],
                  ]
  }
  
  
}#end setup.pp

