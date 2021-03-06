module Fog
  module Compute
    class RackspaceV2
      class Real
        def create_server(name, image_id, flavor_id, min_count, max_count, options = {})
          data = {
            'server' => {
              'name' => name,
              'imageRef' => image_id,
              'flavorRef' => flavor_id,
              'minCount' => min_count,
              'maxCount' => max_count
            }
          }

          data['server']['metadata'] = options[:metadata]  unless options[:metadata].nil?
          data['server']['OS-DCF:diskConfig'] = options[:disk_config] unless options[:disk_config].nil?
          data['server']['metadata'] = options[:metadata] unless options[:metadata].nil?
          data['server']['personality'] = options[:personality] unless options[:personality].nil?
          data['server']['networks'] = options[:networks] || [
            { :uuid => '00000000-0000-0000-0000-000000000000' },
            { :uuid => '11111111-1111-1111-1111-111111111111' }
          ]

          request(
            :body => Fog::JSON.encode(data),
            :expects => [202],
            :method => 'POST',
            :path => "servers"
          )
        end
      end

      class Mock
        def create_server(name, image_id, flavor_id, min_count, max_count, options={})
          server_id   = Fog::Rackspace::MockData.uuid
          public_ip4  = Fog::Rackspace::MockData.ipv4_address
          public_ip6  = Fog::Rackspace::MockData.ipv6_address
          private_ip4 = Fog::Rackspace::MockData.ipv4_address
          private_ip6 = Fog::Rackspace::MockData.ipv6_address
          admin_pass  = Fog::Mock.random_letters(12)

          flavor = self.data[:flavors][flavor_id]
          image  = self.data[:images][image_id]

          server = {
            "OS-DCF:diskConfig"      => "AUTO",
            "OS-EXT-STS:power_state" => 1,
            "OS-EXT-STS:task_state"  => nil,
            "OS-EXT-STS:vm_state"    => "active",
            "accessIPv4" => public_ip4,
            "accessIPv6" => public_ip6,
            "addresses" => {
              "private" => [
                {
                  "addr" => private_ip4,
                  "version" => 4
                }
              ],
                "public" => [
                  {
                    "addr" => public_ip4,
                    "version" => 4
                  },
                  {
                    "addr" => public_ip6,
                    "version" => 6
                  }
              ]
            },
            "created" => "2012-07-28T15:32:25Z",
            "flavor" => Fog::Rackspace::MockData.keep(flavor, "id", "links"),
            "hostId" => Fog::Mock.random_hex(56),
            "id" => server_id,
            "image"  => Fog::Rackspace::MockData.keep(image, "id", "links"),
            "links" => [
              {
                "href" => "https://dfw.servers.api.rackspacecloud.com/v2/010101/servers/#{server_id}",
                "rel" => "self",
              },
              {
                "href" => "https://dfw.servers.api.rackspacecloud.com/010101/servers/#{server_id}",
                "rel" => "bookmark",
              }
            ],
            "metadata" => {},
            "name" => name,
            "progress" => 100,
            "rax-bandwidth:bandwidth" => [
              {
                "audit_period_end"   => "2012-08-16T14:12:00Z",
                "audit_period_start" => "2012-08-16T06:00:00Z",
                "bandwidth_inbound"  => 39147845,
                "bandwidth_outbound" => 13390651,
                "interface"          => "public",
              },
              {
                "audit_period_end"   => "2012-08-16T14:12:00Z",
                "audit_period_start" => "2012-08-16T06:00:00Z",
                "bandwidth_inbound"  => 24229191,
                "bandwidth_outbound" => 84,
                "interface"          => "private",
              }
            ],
            "status"             => "ACTIVE",
            "tenant_id"          => "010101",
            "updated"            => "2012-07-28T15:37:09Z",
            "user_id"            => "170454",
            :volume_ids          => [],
          }

          self.data[:servers][server_id] = server

          response = {
            "server" => {
              "OS-DCF:diskConfig" => "AUTO",
              "adminPass" => admin_pass,
              "id" => server_id,
              "links" => [
                {
                  "href" => "https://dfw.servers.api.rackspacecloud.com/v2/010101/servers/#{server_id}",
                  "rel"  => "self"
                  },
                  {
                  "href" => "https://dfw.servers.api.rackspacecloud.com/010101/servers/#{server_id}",
                  "rel"  => "bookmark"
                }
              ]
            }
          }

          response(:body => response)
        end
      end
    end
  end
end
