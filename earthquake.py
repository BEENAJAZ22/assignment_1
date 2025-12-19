import requests
import pandas as pd
from datetime import datetime
from dateutil.relativedelta import relativedelta

print("Program started")

url = "https://earthquake.usgs.gov/fdsnws/event/1/query"

all_data = []

end_date = datetime.utcnow()
start_date = end_date - relativedelta(years=5)

current_date = start_date

while current_date < end_date:

    start = current_date.strftime("%Y-%m-%d")
    end = (current_date + relativedelta(months=1)).strftime("%Y-%m-%d")

    print("Fetching:", start, "to", end)

    params = {
        "format": "geojson",
        "starttime": start,
        "endtime": end,
        "minmagnitude": 3
    }

    response = requests.get(url, params=params)
    data = response.json()

    events = data["features"]
    print("Records this month:", len(events))

    for event in events:
        p = event["properties"]
        g = event["geometry"]["coordinates"]

        all_data.append({

            # 1–3
            "id": event["id"],
            "time": pd.to_datetime(p.get("time"), unit="ms"),
            "updated": pd.to_datetime(p.get("updated"), unit="ms"),

            # 4–6
            "latitude": g[1],
            "longitude": g[0],
            "depth_km": g[2],

            # 7–10
            "mag": p.get("mag"),
            "magType": p.get("magType"),
            "place": p.get("place"),
            "status": p.get("status"),

            # 11–14
            "tsunami": p.get("tsunami"),
            "sig": p.get("sig"),
            "net": p.get("net"),
            "nst": p.get("nst"),

            # 15–18
            "dmin": p.get("dmin"),
            "rms": p.get("rms"),
            "gap": p.get("gap"),
            "magError": p.get("magError"),

            # 19–22
            "depthError": p.get("depthError"),
            "magNst": p.get("magNst"),
            "locationSource": p.get("locationSource"),
            "magSource": p.get("magSource"),

            # 23–26
            "types": p.get("types"),
            "ids": p.get("ids"),
            "sources": p.get("sources"),
            "type": p.get("type")
        })

    current_date = current_date + relativedelta(months=1)

print("Total records collected:", len(all_data))

df = pd.DataFrame(all_data)

print("Total columns:", len(df.columns))


df["year"] = df["time"].dt.year
df["month"] = df["time"].dt.month
df["day"] = df["time"].dt.day
df["day_of_week"] = df["time"].dt.day_name()

df["depth_category"] = df["depth_km"].apply(
    lambda x: "Shallow" if x < 70 else "Intermediate" if x < 300 else "Deep"
)

import re

def extract_country(place):
    if pd.isna(place):
        return None
    parts = place.split(",")
    return parts[-1].strip()

df["country"] = df["place"].apply(extract_country)

print(df)


from db_config import get_connection
import numpy as np

conn = get_connection()
cursor = conn.cursor()


# FIX ALL NaN TYPES (numeric + string)
df = df.replace({np.nan: None, "nan": None, "NaN": None, "None": None})


insert_query = """
INSERT INTO earthquakes (
    id, place, mag, magType, time,
    latitude, longitude, depth_km,
    sig, tsunami, status,
    net, nst, rms, gap,
    magSource, locationSource
)
VALUES (%s, %s, %s, %s, %s,
        %s, %s, %s,
        %s, %s, %s,
        %s, %s, %s, %s,
        %s, %s)
"""

data = df[[
    "id", "place", "mag", "magType", "time",
    "latitude", "longitude", "depth_km",
    "sig", "tsunami", "status",
    "net", "nst", "rms", "gap",
    "magSource", "locationSource"
]].values.tolist()

cursor.executemany(insert_query, data)
conn.commit()

cursor.close()
conn.close()



print("✅ Data inserted into MySQL successfully using cursor + commit")
