import uuid
import random
from datetime import datetime, timedelta
import psycopg2

conn = psycopg2.connect(
    host="private-rds-vpn-dev-postgres.csz86mgkyb0v.us-east-1.rds.amazonaws.com",
    user="postgres",
    password="postgres123",
    dbname="analytics",
    port=5432
)

countries = ["KE", "UG", "TZ", "RW"]
statuses = ["SUCCESS", "FAILED", "PENDING"]

cur = conn.cursor()

customers = []

for _ in range(200):
    cid = str(uuid.uuid4())
    customers.append(cid)

    cur.execute(
        """
        INSERT INTO raw.customers
        VALUES (%s,%s,%s,%s,%s)
        """,
        (
            cid,
            f"Customer_{random.randint(1,10000)}",
            f"user{random.randint(1,10000)}@email.com",
            random.choice(countries),
            datetime.now() - timedelta(days=random.randint(1,365))
        )
    )

for _ in range(1000):
    cur.execute(
        """
        INSERT INTO raw.transactions
        VALUES (%s,%s,%s,%s,%s,%s)
        """,
        (
            str(uuid.uuid4()),
            random.choice(customers),
            round(random.uniform(5,500),2),
            "USD",
            random.choice(statuses),
            datetime.now() - timedelta(days=random.randint(1,365))
        )
    )

conn.commit()
cur.close()
conn.close()

print("Data generated")