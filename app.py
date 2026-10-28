
import json
import ollama
import pandas as pd
import streamlit as st


# Load retail sales dataset
df = pd.read_csv("retail_sales_analysis_clean.csv")
df["Order Date"] = pd.to_datetime(df["Order Date"])


# Calculate revenue using optional filters
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


# Extract sales channel directly from the question
# This prevents Ollama from inventing channel filters
def extract_channel(question):
    question = question.lower()

    if "online" in question:
        return "Online"
    elif "physical" in question or "in-store" in question:
        return "Physical Store"

    return None


# Interpret business questions and calculate revenue
def ask_retail_ai(question):
    valid_categories = df["Category"].dropna().unique().tolist()

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
                2. Interpret sales as revenue.
                3. Include a year only when explicitly mentioned.
                4. Include a category only when explicitly mentioned.
                5. Never guess missing information.
                6. Use JSON null for missing values.
                7. Category must match one of: {valid_categories}
                8. Channel must be Online, Physical Store, or null.
                9. If no sales channel is mentioned, return null.
                10. Return exactly four fields:
                    metric, year, category, channel.
                11. Return JSON only.

                Example:
                Question: What was the Computers revenue in 2019?
                Answer: {{"metric": "revenue", "year": 2019,
                          "category": "Computers", "channel": null}}
                """
            }
        ],
        format="json"
    )

    result = json.loads(response["message"]["content"])

    # Normalize missing values
    for key in ["metric", "year", "category", "channel"]:
        if isinstance(result.get(key), str):
            if result[key].strip().lower() in ["null", "none", ""]:
                result[key] = None

    # Currently support revenue questions only
    if result.get("metric") != "revenue":
        return "Currently, I can answer revenue questions only."

    # Validate year
    year = result.get("year")

    if year is not None:
        try:
            year = int(year)
        except (ValueError, TypeError):
            return "Sorry, I could not identify a valid year."

    # Validate category
    category = result.get("category")

    if category is not None and category not in valid_categories:
        return "Sorry, I could not identify a valid product category."

    # Extract channel using Python instead of Ollama
    channel = extract_channel(question)

    # Calculate revenue from actual sales data
    revenue = calculate_revenue(
        df,
        year=year,
        category=category,
        channel=channel
    )

    return f"Revenue: ${revenue:,.2f}"


# Streamlit user interface
st.title("Retail Sales AI Assistant")

st.write("Ask questions about retail sales revenue.")

question = st.text_input("Enter your business question:")

if st.button("Ask AI"):
    if question.strip():
        with st.spinner("Analyzing your question..."):
            try:
                answer = ask_retail_ai(question)
                st.write(answer)
            except Exception:
                st.error(
                    "Unable to process the question. "
                    "Please check that Ollama is running and try again."
                )
    else:
        st.warning("Please enter a business question.")
