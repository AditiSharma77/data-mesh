job "nifi" {

  datacenters = ["dc1"]
  type = "service"

  group "servers" {
    count = 1
    network {
      mode = "bridge"
    }
    service {
      name ="nifi"
      port = 8999
      check {
        expose   = true
        name     = "nifi"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
      connect {
        sidecar_service {}
      }
    }
    task "nifi" {
      driver = "docker"
      config {
        image = "apache/nifi:1.11.4"
        //image = "${harbor}/nifi/nifi:latest"
      }
      resources {
        cpu    = 1000 # MHz
        memory = 1024 # MB
      }
    }
  }
}