#!/usr/bin/env python3
"""Architecture diagram for oci-architect-associate-lab.

Diagram-as-code so the picture lives in the repository and changes with it,
rather than as a binary someone has to open an editor to update.

Requires the `diagrams` package (Graphviz must be installed separately):

    pip install diagrams
    python diagrams/architecture.py

Produces architecture.png in this directory. The diagram is intentionally
high-level: it shows the VCN, the two tiers, the three gateways and the resource
families, which is the vocabulary the exam uses.
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.oci.compute import Instance, InstancePools
from diagrams.oci.database import Storage as ObjectStorage
from diagrams.oci.network import (
    InternetGateway,
    NATGateway,
    RouteTable,
    SecurityLists,
    ServiceGateway,
    Vcn,
)
from diagrams.oci.storage import BlockStorage, FileStorage


def main() -> None:
    graph_attr = {
        "fontsize": "14",
        "labelloc": "t",
        "label": "oci-architect-associate-lab\n"
                 "networking 35% | storage 25% | compute 20% | iam 20%",
        "pad": "0.5",
    }

    with Diagram(
        "OCI Architect Associate lab",
        filename="architecture",
        outformat="png",
        show=False,
        direction="TB",
        graph_attr=graph_attr,
    ):
        internet = InternetGateway("internet")

        with Cluster("VCN 10.20.0.0/16"):
            vcn = Vcn("vcn")

            with Cluster("Gateways"):
                igw = InternetGateway("igw")
                nat = NATGateway("nat")
                sgw = ServiceGateway("service gateway")

            with Cluster("Public subnet 10.20.0.0/24"):
                RouteTable("rt-public")
                SecurityLists("sl-public")
                app = Instance("app vm")

            with Cluster("Private subnet 10.20.1.0/24"):
                RouteTable("rt-private")
                SecurityLists("sl-private")
                pool = InstancePools("instance pool")
                files = FileStorage("file storage")

            block = BlockStorage("block volume")
            bucket = ObjectStorage("object storage")

        internet >> Edge(label="ingress") >> igw
        igw >> Edge(label="in") >> app
        app >> Edge(label="data") >> block
        vcn >> [igw, nat, sgw]
        nat >> Edge(label="outbound only") >> pool
        sgw >> Edge(label="OCI services") >> bucket
        pool - files


if __name__ == "__main__":
    main()