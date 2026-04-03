# db9 fs + Claude Code — Docker Example

Run Claude Code inside a Docker container with a [db9](https://db9.ai) remote filesystem mounted at `/mnt/db9fs`.

## Prerequisites

- Docker + Docker Compose
- [db9 CLI](https://db9.ai) installed on your host

```bash
curl -fsSL https://db9.ai/install | sh
```

---

## Step 1 — Create a database

```bash
db9 create --name mydb
```

Note the database name from the output.

## Step 2 — Create an API token

```bash
db9 token create --name docker-example
```

Copy the token — it's only shown once.

## Step 3 — Set environment variables

```bash
export DB9_API_KEY=<your token>
export DB9_DBNAME=mydb        # optional — omit to auto-create a new db
```

## Step 4 — Launch the container

```bash
docker compose run --rm db9-fuse
```

The container will:
1. Authenticate with db9
2. Mount the db9 filesystem at `/mnt/db9fs`
3. Start Claude Code in that directory

Log in to Claude when prompted, then start working — all files Claude reads and writes live in your db9 database.

## Step 5 — Watch the filesystem from your host

In a separate terminal on your host:

```bash
db9 fs watch mydb:/
```

You'll see every file change Claude makes in real time.
