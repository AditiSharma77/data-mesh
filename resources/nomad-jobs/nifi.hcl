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
nifi.content.repository.s3_path_style_access=true
nifi.content.repository.s3_cache=10000
nifi.content.repository.directory.default=/nifiminio
nifi.content.repository.archive.enabled=true
nifi.content.viewer.url=../nifi-content-viewer/
EOH
      }

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

      }
    }

}