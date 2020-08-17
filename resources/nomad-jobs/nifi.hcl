job "nifi" {

  datacenters = ["dc1"]
  type = "service"

  group "servers" {
    count = 1
    task "nifi" {
      driver = "docker"

      config {
        image = "apache/nifi:1.11.4"
        //image = "${harbor}/nifi/nifi:latest"

        port_map {
          nifi = 8999
        }
      }

      service {
        port = "nifi"


      }

      resources {
        cpu    = 1000 # MHz
        memory = 1024 # MB

        network {
          mbits = 100

          port "nifi" {
          }
        }
      }
    }
  }
}