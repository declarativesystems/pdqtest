class apache::bad_syntax {
  file { "/this/file/results/in/syntax/error":
    ensure => file
    owner => root
    group => root
  }
}
