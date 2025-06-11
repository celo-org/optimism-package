shared_utils = import_module(
    "github.com/ethpandaops/ethereum-package/src/shared_utils/shared_utils.star"
)
constants = import_module(
    "github.com/ethpandaops/ethereum-package/src/package_io/constants.star"
)
da_server_launcher = import_module("../da-server/da_server_launcher.star")

# Port IDs
DA_PROXY_HTTP_PORT_ID = "http"

# Port nums
DA_PROXY_HTTP_PORT_NUM = 8080

def get_used_ports():
    used_ports = {
        DA_PROXY_HTTP_PORT_ID: shared_utils.new_port_spec(
            DA_PROXY_HTTP_PORT_NUM,
            shared_utils.TCP_PROTOCOL,
            shared_utils.HTTP_APPLICATION_PROTOCOL,
        ),
    }
    return used_ports


def get_da_proxy_config(
    plan,
    image,
    upstream_url,
    maintenance
):
    return ServiceConfig(
        image=image,
        ports=get_used_ports(),
        cmd=[
            "python",
            "server.py"
        ],
        private_ip_address_placeholder=constants.PRIVATE_IP_ADDRESS_PLACEHOLDER,
        env_vars={
            "UPSTREAM_URL": upstream_url,
            "MAINTENANCE_MODE": str(maintenance).lower()
        }
    )

def launch_da_proxy(plan, service_name, image, upstream_url, maintenance):
    svc_conf = get_da_proxy_config(
        plan,
        image,
        upstream_url,
        maintenance
    )

    da_proxy_service = plan.add_service(name=service_name, config=svc_conf)

    proxy_url = "http://{0}:{1}".format(
        da_proxy_service.ip_address, DA_PROXY_HTTP_PORT_NUM
    )

    return da_server_launcher.new_da_server_context(
        http_url=proxy_url,
    )
