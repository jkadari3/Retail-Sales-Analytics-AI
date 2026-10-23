import ollama
import json
import streamlit as st
import pandas as pd

df = pd.read_csv("retail_sales_analysis_clean.csv")
df["Order Date"] = pd.to_datetime(df["Order Date"])
def calculate_revenue(data, year=None, category=None, channel=None):
    filtered_data = data.copy()

    if year is not None:
        filtered_data = filtered_data[
            filtered_data["Order Date"].dt.year == year
        ]

    if category is not None:
        filtered_data = filtered_data[
            filtered_data["Category"] == category
        ]

    if channel == "Online":
        filtered_data = filtered_data[
            filtered_data["StoreKey"] == 0
        ]
    elif channel == "Physical Store":
        filtered_data = filtered_data[
            filtered_data["StoreKey"] != 0
        ]

    return round(filtered_data["Revenue USD"].sum(), 2)
    
def ask_retail_ai(question):
    response = ollama.chat(
        model="llama3.2:3b",
        messages=[
            {
                "role": "user",
                "content": f"""
                Extract these four fields from the retail business question:
                metric, year, category, channel.

                Question: {question}

                Rules:
                1. For revenue questions, return metric as "revenue".
                2. Include a year only when explicitly mentioned.
                3. Include a category only when explicitly mentioned.
                4. Include a channel only when explicitly mentioned.
                5. Never guess missing information.
                6. Use JSON null for missing values.
                7. Use "Computers" for computer-related questions.
                8. Use "Online" or "Physical Store" for sales channels.
                9. Return exactly four fields:
                   metric, year, category, channel.

Example:
Question: What was the Computers revenue in 2019?
Answer: {{"metric": "revenue", "year": 2019, "category": "Computers", "channel": null}}
                Return JSON only.
                """
            }
        ],
        format="json"
    )

    result = json.loads(response["message"]["content"])

    if result.get("channel") in ["null", "None", ""]:
        result["channel"] = None

    valid_categories = df["Category"].dropna().unique()

    if result.get("category") is not None:
        if result["category"] not in valid_categories:
            return "Sorry, I could not identify a valid product category."

    valid_channels = ["Online", "Physical Store"]

    if result.get("channel") is not None:
        if result["channel"] not in valid_channels:
            return "Sorry, I could not identify a valid sales channel."

    if result.get("metric", "").lower() != "revenue":
        return "Currently, I can answer revenue questions only."

    revenue = calculate_revenue(
        df,
        year=int(result["year"]) if result.get("year") else None,
        category=result.get("category"),
        channel=result.get("channel")
    )

    return f"Revenue: ${revenue:,.2f}"
    result = json.loads(response["message"]["content"])
    st.write("AI interpretation:", result)

    if result.get("channel") in ["null", "None", ""]:
        result["channel"] = None

    valid_categories = df["Category"].dropna().unique()

    if result.get("category") is not None:
        if result["category"] not in valid_categories:
            return "Sorry, I could not identify a valid product category."

    valid_channels = ["Online", "Physical Store"]

    if result.get("channel") is not None:
        if result["channel"] not in valid_channels:
            return "Sorry, I could not identify a valid sales channel."

    if result.get("metric", "").lower() != "revenue":
        return "Currently, I can answer revenue questions only."

    revenue = calculate_revenue(
        df,
        year=int(result["year"]) if result.get("year") else None,
        category=result.get("category"),
        channel=result.get("channel")
    )

    return f"Revenue: ${revenue:,.2f}"    

st.title("Retail Sales AI Assistant")

st.write("Ask questions about retail sales revenue.")

question = st.text_input("Enter your business question:")

if st.button("Ask AI"):
    if question.strip():
        with st.spinner("Analyzing your question..."):
            answer = ask_retail_ai(question)

        st.write(answer)
    else:
        st.warning("Please enter a business question.")