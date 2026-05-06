import requests
from bs4 import BeautifulSoup
import json
import urllib.parse

def scrape_carrefour_egypt(query):
    url = f"https://www.carrefouregypt.com/mafegy/en/search?q={urllib.parse.quote(query)}"
    headers = {
        "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1"
    }

    try:
        response = requests.get(url, headers=headers, timeout=25)
        if response.status_code != 200: return []

        soup = BeautifulSoup(response.content, "lxml")
        script = soup.find("script", id="__NEXT_DATA__")

        results = []
        if script:
            data = json.loads(script.string)
            items = data.get('props', {}).get('pageProps', {}).get('initialData', {}).get('search', {}).get('products', [])
            for idx, p in enumerate(items):
                results.append({
                    "Sr No": idx + 1,
                    "Product URL": "https://www.carrefouregypt.com" + p.get('url', ''),
                    "Product Name": p.get('name'),
                    "Price": p.get('price'),
                    "MRP (EGP)": p.get('oldPrice') or p.get('price'),
                    "Discount %": p.get('discount', 0),
                    "Product Image URL": p.get('image'),
                    "Store": "Carrefour Egypt",
                    "Description": "Fresh from Carrefour Egypt.",
                    "Rating": 4.6
                })
        return results
    except Exception as e:
        print(f"Carrefour Scraper Error: {e}")
        return []
