class apache::bad_lint {
  # a class with bad style but no syntax errors
  file { "/myfile":
    ensure => file,
    owner => "root",
    group => "root",
    mode => "0755",
    content => "the arrows are missaligned and this is unstylish...",
  }

}
