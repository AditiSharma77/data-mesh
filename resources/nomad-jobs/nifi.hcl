job "nifi" {
  datacenters = ["dc1"]
  type = "service"
  update {
    max_parallel      = 1
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "12m"
    progress_deadline = "15m"
    auto_revert       = true
    auto_promote      = true
    canary            = 1
    stagger           = "30s"
  }
  group "nifi" {
    count = 1

    network {
      mode = "bridge"
    }
    service {
      name = "nifi"
      port = 8999
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "minio"
              local_bind_port = 9000
            }
          }
        }
      }
      check {
        expose   = true
        name     = "nifi"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }
    task "nifi" {
      driver = "docker"
      config {
        image = "apache/nifi:1.11.3"
       volumes = [
          "local/conf/nifi.properties:/local/conf/nifi.properties",
        ]
      }
      template {
        data = <<EOH
          MINIO_ACCESS_KEY = "minioadmin"
          MINIO_SECRET_KEY = "minioadmin"
          EOH
        destination = "secrets/.env"
        env         = true
      }
      template {
        destination = "/local/conf/nifi.properties"
        data = <<EOH
        nifi.content.repository.implementation=io.minio.nifi.MinIORepository
        nifi.content.claim.max.appendable.size=1 MB
        nifi.content.claim.max.flow.files=1000
# S3 specific settings
        nifi.content.repository.s3_endpoint=http://{{ env "NOMAD_UPSTREAM_ADDR_minio" }}
        nifi.content.repository.s3_access_key={{ env "MINIO_ACCESS_KEY" }}
        nifi.content.repository.s3_secret_key={{ env "MINIO_SECRET_KEY" }}
        nifi.content.repository.s3_ssl_enabled=true

EOH
      }
      }

      }
  }

