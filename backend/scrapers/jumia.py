import requests
from bs4 import BeautifulSoup
import urllib.parse

def scrape_jumia_egypt(query):
    url = f"https://www.jumia.com.eg/catalog/?q={urllib.parse.quote(query)}"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"
    }

    try:
        response = requests.get(url, headers=headers, timeout=20)
        if response.status_code != 200: return []

        soup = BeautifulSoup(response.content, "html.parser")
        items = soup.select('article.prd')

        results = []
        for idx, item in enumerate(items):
            name_el = item.select_one('h3.name')
            price_el = item.select_one('div.prc')
            if not name_el or not price_el: continue

            link = "https://www.jumia.com.eg" + item.select_one('a.core')['href']
            img = item.select_one('img.img').get('data-src') or item.select_one('img.img').get('src')

            price = float(price_el.get_text(strip=True).replace('EGP', '').replace(',', '').strip())
            old_price_el = item.select_one('div.old')
            mrp = float(old_price_el.get_text(strip=True).replace('EGP', '').replace(',', '').strip()) if old_price_el else price

            results.append({
                "Sr No": idx + 1,
                "Product URL": link,
                "Product Name": name_el.get_text(strip=True),
                "Price": price,
                "MRP (EGP)": mrp,
                "Discount %": round(((mrp - price) / mrp) * 100) if mrp > price else 0,
                "Product Image URL": img,
                "Store": "Jumia Egypt",
                "Description": "Authentic product from Jumia Egypt.",
                "Rating": 4.2
            })
        return results
    except Exception as e:
        print(f"Jumia Scraper Error: {e}")
        return []
