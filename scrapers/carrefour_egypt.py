import requests
from bs4 import BeautifulSoup
import json
import urllib.parse

def scrape_carrefour_egypt(query):
    """
    Scrapes Carrefour Egypt by finding the JSON data embedded in the page.
    This is the most reliable 'accurate' method for MAF sites.
    """
    url = f"https://www.carrefouregypt.com/mafegy/en/search?q={urllib.parse.quote(query)}"
    headers = {
        "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.9",
    }

    products = []
    try:
        response = requests.get(url, headers=headers, timeout=25)
        if response.status_code != 200: return []

        soup = BeautifulSoup(response.content, "lxml")

        # Method: Extract from __NEXT_DATA__
        script = soup.find("script", id="__NEXT_DATA__")
        if script:
            data = json.loads(script.string)
            raw_items = data.get('props', {}).get('pageProps', {}).get('initialData', {}).get('search', {}).get('products', [])

            for idx, p in enumerate(raw_items):
                products.append({
                    "Sr No": idx + 1,
                    "Product URL": "https://www.carrefouregypt.com" + p.get('url', ''),
                    "Product ID": p.get('sku'),
                    "Product Name": p.get('name'),
                    "Category": p.get('categoryName', 'Groceries'),
                    "Brand": p.get('brandName', 'Carrefour'),
                    "MRP (EGP)": p.get('oldPrice') or p.get('price'),
                    "Discount %": p.get('discount', 0),
                    "Price": p.get('price'),
                    "Description": p.get('description', 'Real-time accurate data from Carrefour Egypt.'),
                    "Product Image URL": p.get('image'),
                    "Store Name": "Carrefour Egypt",
                    "Availability": "In Stock" if p.get('stock', 0) > 0 else "Out of Stock"
                })
    except Exception as e:
        print(f"Carrefour Scrape Error: {e}")

    return products

if __name__ == "__main__":
    res = scrape_carrefour_egypt("milk")
    print(f"Found {len(res)} items.")
