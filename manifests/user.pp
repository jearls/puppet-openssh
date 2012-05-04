define ssh::user($username=$title, $uid, $gid, $gecos, $additional_groups, $shell="/bin/bash", $pwhash='', $ssh_key) {
    # Create a usergroup
    group { $username:
        ensure => present,
        gid => $gid,
    }

    user { $username:
        ensure => present,
        uid => $uid,
        gid => $gid,
        groups => $additional_groups,
        shell => $shell,
        comment => $gecos,
        managehome => true,
        home => "/home/${username}",
        require => [
            Group[$additional_groups],
            Group[$username]
        ],

    }

    # Set password if available
    if $pwhash != '' {
        User <| title == "$username" |> { password => $pwhash }
    }

    file { "/home/${username}/.ssh":
        ensure => directory,
        owner => $username,
        group => $username,
        mode => '0700',
    }

    if $ssh_key {
        ssh_authorized_key { $ssh_key["comment"]:
             ensure => present,
             user => $username,
             type => $ssh_key["type"],
             key => $ssh_key["key"],
        }
    }
}
