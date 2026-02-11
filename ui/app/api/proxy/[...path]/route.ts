import { NextRequest, NextResponse } from "next/server";

const handler = async (
  request: NextRequest,
  props: { params: Promise<{ path: string[] }> },
) => {
  const params = await props.params;
  const path = params.path.join("/");

  // Remove trailing slash from base URL if present
  let baseUrl =
    process.env.INTERNAL_API_URL ||
    process.env.NEXT_PUBLIC_API_URL ||
    "http://localhost:8080";

  if (baseUrl.endsWith("/")) {
    baseUrl = baseUrl.slice(0, -1);
  }

  const targetUrl = `${baseUrl}/${path}`;
  console.log(`[Proxy] Forwarding to: ${targetUrl}`);

  try {
    const isBodyRequest = ["POST", "PUT", "PATCH"].includes(request.method);
    const body = isBodyRequest ? await request.text() : undefined;

    const response = await fetch(targetUrl, {
      method: request.method,
      headers: {
        "Content-Type": "application/json",
        ...(request.headers.get("Authorization")
          ? { Authorization: request.headers.get("Authorization")! }
          : {}),
      },
      body,
    });

    const data = await response.json();
    return NextResponse.json(data, { status: response.status });
  } catch (error) {
    console.error("Proxy error:", error);
    return NextResponse.json(
      { error: "Failed to fetch data from backend" },
      { status: 500 },
    );
  }
};

export {
  handler as GET,
  handler as POST,
  handler as PUT,
  handler as DELETE,
  handler as PATCH,
};
