import { NextResponse } from "next/server";
import { ServerInfo } from "@/types/omikuji";

async function getMetadata(path: string): Promise<string | null> {
  try {
    // IMDSv2 Token
    const tokenRes = await fetch("http://169.254.169.254/latest/api/token", {
      method: "PUT",
      headers: {
        "X-aws-ec2-metadata-token-ttl-seconds": "21600",
      },
      signal: AbortSignal.timeout(1000), // Timeout 1s
    });

    if (!tokenRes.ok) return null;
    const token = await tokenRes.text();

    // Get Metadata
    const res = await fetch(`http://169.254.169.254/latest/meta-data/${path}`, {
      headers: {
        "X-aws-ec2-metadata-token": token,
      },
      signal: AbortSignal.timeout(1000),
    });

    if (!res.ok) return null;
    return await res.text();
  } catch {
    return null;
  }
}

export async function GET() {
  const isLocal = process.env.NODE_ENV === "development";

  let info: ServerInfo = {
    hostname: "unknown",
    private_ip: "unknown",
    instance_id: "unknown",
    availability_zone: "unknown",
  };

  if (isLocal) {
    info = {
      hostname: "localhost",
      private_ip: "127.0.0.1",
      instance_id: "i-local-dev",
      availability_zone: "local-zone-1a",
    };
  } else {
    // Try allow getting real metadata in production
    const [hostname, localIpv4, instanceId, placement] = await Promise.all([
      getMetadata("hostname"),
      getMetadata("local-ipv4"),
      getMetadata("instance-id"),
      getMetadata("placement/availability-zone"),
    ]);

    if (hostname) info.hostname = hostname;
    if (localIpv4) info.private_ip = localIpv4;
    if (instanceId) info.instance_id = instanceId;
    if (placement) info.availability_zone = placement;
  }

  return NextResponse.json(info);
}
