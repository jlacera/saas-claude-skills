---
max_turns: 10
allowed_tools: [Skill, Read, Glob, Grep]
---

Revisa este diff antes de que lo mergee:

```ts
// app/api/reports/route.ts
export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const orgId = searchParams.get("orgId");
  const rows = await prisma.$queryRawUnsafe(`SELECT * FROM reports WHERE org_id = '${orgId}'`);
  return Response.json(rows);
}
```
