from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import numpy as np
import pdfplumber
import google.generativeai as genai
from sklearn.linear_model import LinearRegression, LogisticRegression, Ridge, Lasso
from sklearn.preprocessing import PolynomialFeatures, OneHotEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, confusion_matrix, mean_squared_error, r2_score
import xgboost as xgb
import seaborn as sns
import matplotlib.pyplot as plt
import io
import base64
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import google.generativeai as genai
from PIL import Image
import io

app = FastAPI()
from fastapi.responses import JSONResponse


# Allow CORS from Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure Google Gemini API
GOOGLE_API_KEY = "api_key"
genai.configure(api_key=GOOGLE_API_KEY)

### Helper Functions ###
def extract_text_from_pdf(file):
    text = ""
    with pdfplumber.open(file) as pdf:
        for page in pdf.pages:
            text += page.extract_text()
    return text

@app.post("/summarize_text")
async def summarize_text(text: str = Form(...)):
    model = genai.GenerativeModel('gemini-2.0-flash')
    response = model.generate_content("Summarize following\n" + text)
    return {"summary": response.text}

@app.post("/summarize_pdf")
async def summarize_pdf(file: UploadFile = File(...)):
    text = extract_text_from_pdf(file.file)
    model = genai.GenerativeModel('gemini-2.0-flash')
    response = model.generate_content("Summarize following\n" + text)
    return {"summary": response.text}

@app.post("/translate_text")
async def translate_text(text: str = Form(...), target_language: str = Form(...)):
    model = genai.GenerativeModel('gemini-2.0-flash')
    prompt = f"Translate the following text to {target_language}:\n{text}"
    response = model.generate_content(prompt)
    translated_text = response.text
    return JSONResponse(content={"translated_text": translated_text}, media_type="application/json; charset=utf-8")

@app.post("/generate_assignments")
async def generate_assignments(file: UploadFile = File(...), level: str = Form(...)):
    text = extract_text_from_pdf(file.file)
    model = genai.GenerativeModel('gemini-2.0-flash')
    prompt = f"Generate {level} level questions from the following:\n{text}"
    response = model.generate_content(prompt)
    return {"assignments": response.text}

@app.post("/generate_study_plan")
async def generate_study_plan(subjects: dict):
    study_plan = []
    for subject, topics in subjects.items():
        for topic, duration in topics.items():
            study_plan.append({"Subject": subject, "Topic": topic, "Duration": duration})
    return {"study_plan": study_plan}

@app.post("/linear_regression")
async def linear_regression(file: UploadFile = File(...), features: list = Form(...), target: str = Form(...)):
    df = pd.read_csv(file.file)
    X = df[features]
    y = df[target]
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    model = LinearRegression().fit(X_train, y_train)
    predictions = model.predict(X_test)

    mse = mean_squared_error(y_test, predictions)
    r2 = r2_score(y_test, predictions)

    return {"mse": mse, "r2": r2}

@app.post("/logistic_regression")
async def logistic_regression(file: UploadFile = File(...), features: list = Form(...), target: str = Form(...)):
    df = pd.read_csv(file.file)
    X = df[features]
    y = df[target]
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    model = LogisticRegression().fit(X_train, y_train)
    predictions = model.predict(X_test)

    accuracy = accuracy_score(y_test, predictions)
    cm = confusion_matrix(y_test, predictions).tolist()

    return {"accuracy": accuracy, "confusion_matrix": cm}

@app.post("/polynomial_regression")
async def polynomial_regression(file: UploadFile = File(...), features: list = Form(...), target: str = Form(...), degree: int = Form(2)):
    df = pd.read_csv(file.file)
    X = df[features]
    y = df[target]

    poly = PolynomialFeatures(degree=degree)
    X_poly = poly.fit_transform(X)

    model = LinearRegression().fit(X_poly, y)
    predictions = model.predict(X_poly)

    mse = mean_squared_error(y, predictions)
    r2 = r2_score(y, predictions)

    return {"mse": mse, "r2": r2}

@app.post("/xgboost_classifier")
async def xgboost_classifier(file: UploadFile = File(...), features: list = Form(...), target: str = Form(...)):
    df = pd.read_csv(file.file)
    X = df[features]
    y = df[target]

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    model = xgb.XGBClassifier().fit(X_train, y_train)
    predictions = model.predict(X_test)

    accuracy = accuracy_score(y_test, predictions)
    cm = confusion_matrix(y_test, predictions).tolist()

    return {"accuracy": accuracy, "confusion_matrix": cm}

@app.post("/regularization")
async def regularization(file: UploadFile = File(...), features: list = Form(...), target: str = Form(...), method: str = Form(...)):
    df = pd.read_csv(file.file)
    X = df[features]
    y = df[target]

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.5, random_state=42)

    if method == "L1":
        model = Lasso().fit(X_train, y_train)
    else:
        model = Ridge().fit(X_train, y_train)

    train_score = model.score(X_train, y_train)
    test_score = model.score(X_test, y_test)

    return {"train_score": train_score, "test_score": test_score}
@app.post("/check_handwritten_assignment")
async def check_handwritten_assignment(image: UploadFile = File(...), correct_answer: str = Form(...)):
    image_bytes = await image.read()
    pil_image = Image.open(io.BytesIO(image_bytes))

    # Gemini vision model for image to text extraction
    model = genai.GenerativeModel('gemini-2.0-flash')
    prompt = "Extract the handwritten text from the image clearly and accurately."
    response = model.generate_content([prompt, pil_image])

    extracted_text = response.text

    # Now check if the extracted answer is correct
    check_prompt = f"The correct answer is:\n{correct_answer}\n\nStudent's answer:\n{extracted_text}\n\nCheck if the student's answer is correct or incorrect and briefly explain."
    result = model.generate_content(check_prompt)

    correctness_feedback = result.text

    return JSONResponse(content={
        "extracted_text": extracted_text,
        "feedback": correctness_feedback
            }, media_type="application/json; charset=utf-8")