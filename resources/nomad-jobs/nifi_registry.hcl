job "nifiregistry" {

  datacenters = ["dc1"]
  type = "service"

  group "servers" {
    count = 1
    task "nifi-registry" {
      driver = "docker"

      config {
        image = "apache/nifi-registry:0.6.0"
        //image = "${harbor}/nifi/nifi:latest"

        port_map {
          nifiregistry = 10000
        }
      }

      service {
        port = "nifiregistry"


      }

      resources {
        cpu    = 1000 # MHz
        memory = 1024 # MB

        network {
          mbits = 100

          port "nifiregistry" {
          }
        }
      }
    }
  }
}