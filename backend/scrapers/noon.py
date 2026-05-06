import requests
from bs4 import BeautifulSoup
import urllib.parse

def scrape_noon_egypt(query):
    url = f"https://www.noon.com/egypt-en/search/?q={urllib.parse.quote(query)}"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"
    }

    try:
        response = requests.get(url, headers=headers, timeout=20)
        if response.status_code != 200: return []

        soup = BeautifulSoup(response.content, "html.parser")
        items = soup.select('div.productContainer')

        results = []
        for idx, item in enumerate(items):
            name_el = item.select_one('div[data-qa="product-name"]')
            price_el = item.select_one('span.amount')
            if not name_el or not price_el: continue

            link = "https://www.noon.com" + item.select_one('a')['href']
            img_el = item.select_one('img')

            results.append({
                "Sr No": idx + 1,
                "Product URL": link,
                "Product Name": name_el.get_text(strip=True),
                "Price": float(price_el.get_text(strip=True).replace(',', '')),
                "MRP (EGP)": float(price_el.get_text(strip=True).replace(',', '')),
                "Discount %": 0,
                "Product Image URL": img_el.get('src') if img_el else None,
                "Store": "Noon Egypt",
                "Description": "Available on Noon Egypt.",
                "Rating": 4.3
            })
        return results
    except Exception as e:
        print(f"Noon Scraper Error: {e}")
        return []
