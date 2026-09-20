#!/usr/bin/env bash
# quick-scan.sh - Deterministic scan for the 15 adversarial patterns that grep can prove.
# Run from the repository root. Exit code 1 if any CRITICAL pattern matched.
# A clean run does NOT mean the code is safe: it means these 15 patterns are absent.
set -uo pipefail

CRIT=0; WARN=0
SRC=(--include=*.ts --include=*.tsx --include=*.js --include=*.jsx --include=*.py)
EXCL=(--exclude-dir=node_modules --exclude-dir=.next --exclude-dir=dist --exclude-dir=build --exclude-dir=.git --exclude-dir=vendor)

hit() { # hit LEVEL "name" "pattern-output"
  local level="$1" name="$2" out="$3"
  [ -z "$out" ] && return 0
  if [ "$level" = "CRITICAL" ]; then CRIT=$((CRIT+1)); else WARN=$((WARN+1)); fi
  printf '\n[%s] %s\n' "$level" "$name"
  printf '%s\n' "$out" | head -12
}

scan() { grep -rn "${SRC[@]}" "${EXCL[@]}" -E "$1" . 2>/dev/null; }

echo "=== quick-scan.sh :: adversarial pattern scan ==="

hit CRITICAL "D1 Raw SQL sin parametrizar (Prisma Unsafe / concatenacion)" \
  "$(scan '\$(queryRawUnsafe|executeRawUnsafe)')"

hit CRITICAL "N6 Secreto expuesto con prefijo publico" \
  "$(grep -rn -E 'NEXT_PUBLIC_[A-Z_]*(SECRET|KEY|TOKEN|PASSWORD|SERVICE)' --exclude-dir=node_modules --exclude-dir=.git . 2>/dev/null | grep -v 'PUBLISHABLE\|ANON_KEY')"

hit CRITICAL "A2 Asignacion masiva (spread del body al ORM)" \
  "$(scan '(data|values):\s*(\.\.\.)?(req\.body|body|input)\b|Object\.assign\([^,]+,\s*(req\.)?body')"

hit CRITICAL "I1 JWT decodificado sin verificar firma" \
  "$(scan '(jwt\.decode|jwtDecode)\(')"

hit CRITICAL "S3 CORS abierto a cualquier origen" \
  "$(scan "Access-Control-Allow-Origin[\"' :]+\*|origin:\s*[\"']\*[\"']")"

hit CRITICAL "G2 Endpoint de webhook sin verificacion de firma" \
  "$(for f in $( { grep -rl "${SRC[@]}" "${EXCL[@]}" -iE 'webhook' . 2>/dev/null; find . -path ./node_modules -prune -o -ipath '*webhook*' -name '*.ts' -print 2>/dev/null; } | sort -u); do
       grep -qE 'constructEvent|verifyHeader|svix|createHmac|verifySignature|timingSafeEqual' "$f" || echo "$f: sin verificacion de firma";
     done)"

hit CRITICAL "G3 Cron handler sin CRON_SECRET" \
  "$(if [ -f vercel.json ] && grep -q '"crons"' vercel.json; then
       grep -rL "${SRC[@]}" "${EXCL[@]}" -E 'CRON_SECRET' $(grep -rl "${SRC[@]}" "${EXCL[@]}" -E 'export (async )?function (GET|POST)' app/api src/app/api 2>/dev/null) 2>/dev/null | head -5
     fi)"

hit CRITICAL "IA3 Conexion de IA a base de datos con rol privilegiado" \
  "$(scan 'SERVICE_ROLE|service_role' )"

hit WARN "N1 Consulta en Server Component sin select explicito" \
  "$(grep -rn --include=*.tsx "${EXCL[@]}" -E 'findMany\(|findFirst\(|findUnique\(' app src 2>/dev/null | head -8)"

hit WARN "N4 Detalle de error devuelto al cliente" \
  "$(scan '(Response\.json|res\.(json|send)|NextResponse\.json)\([^)]*\.(message|stack)|JSON\.stringify\((error|err)\b')"

hit WARN "A1 Ruta de API sin validacion de esquema" \
  "$(for f in $(find app/api src/app/api pages/api -name '*.ts' 2>/dev/null | head -40); do
       grep -qE 'safeParse|\.parse\(|zValidator|yup\.|joi\.' "$f" || echo "$f: sin validacion de esquema";
     done | head -8)"

hit WARN "R4 Clave de cache sin prefijo de tenant" \
  "$(scan '(redis|cache)\.(set|get|setex)\(' | grep -v 'tenant\|org_id' | head -8)"

hit WARN "A3 Procedimientos tRPC publicos" \
  "$(scan 'publicProcedure' | head -8)"

hit WARN "S1 Dependencias con rango de version abierto" \
  "$(grep -nE '"\^|"~' package.json 2>/dev/null | head -8)"

hit WARN "Ley 2 TODO/FIXME en el codigo" \
  "$(scan '(TODO|FIXME)[:( ]' | head -8)"

echo
echo "=== resumen: ${CRIT} patron(es) CRITICO(s), ${WARN} advertencia(s) ==="
echo "Un resultado limpio solo descarta estos 15 patrones. La auditoria completa exige"
echo "ejecutar los prompts auditores de references/ contra el stack real."
[ "$CRIT" -gt 0 ] && exit 1
exit 0
