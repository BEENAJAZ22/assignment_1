import streamlit as st
import mysql.connector
import pandas as pd

# ---------- DB CONNECTION ----------
def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="root123",
        database="earthquake_db"
    )

# ---------- PAGE CONFIG ----------
st.set_page_config(page_title="Global Seismic Trends", layout="wide")
st.title("🌍 Global Seismic Trends Dashboard")
st.write("Earthquake analysis based on USGS data (last 5 years)")

# ---------- LOAD DATA ----------
@st.cache_data
def load_data():
    conn = get_connection()
    query = "SELECT * FROM earthquakes"
    df = pd.read_sql(query, conn)
    conn.close()
    return df

df = load_data()

# ---------- SIDEBAR FILTERS ----------
st.sidebar.header("Filters")

min_mag = st.sidebar.slider("Minimum Magnitude", 0.0, 10.0, 3.0)
min_depth, max_depth = st.sidebar.slider("Depth range (km)", 0, 700, (0, 700))

filtered_df = df[
    (df['mag'] >= min_mag) &
    (df['depth_km'] >= min_depth) &
    (df['depth_km'] <= max_depth)
]

# ---------- METRICS ----------
col1, col2, col3 = st.columns(3)

col1.metric("Total Earthquakes", len(filtered_df))
col2.metric("Max Magnitude", round(filtered_df['mag'].max(), 2))
col3.metric("Deep Quakes (>300km)", len(filtered_df[filtered_df['depth_km'] > 300]))

# ---------- TABLE ----------
st.subheader("Earthquake Records")
st.dataframe(filtered_df[['time','place','mag','depth_km','status']])

# ---------- CHARTS ----------
st.subheader("Earthquakes per Year")
yearly = filtered_df.copy()
yearly['year'] = pd.to_datetime(yearly['time']).dt.year
st.bar_chart(yearly.groupby('year').size())

st.subheader("Magnitude Distribution")
st.bar_chart(filtered_df['mag'].value_counts().sort_index())

# ---------- MAP ----------
st.subheader("Earthquake Locations")
st.map(filtered_df[['latitude','longitude']])

st.success("Dashboard loaded successfully")
