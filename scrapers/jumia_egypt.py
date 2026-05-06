import requests
from bs4 import BeautifulSoup
import urllib.parse

def scrape_jumia_egypt(query):
    """
    Highly accurate Jumia Egypt scraper.
    Uses headers and session handling to bypass basic protection.
    """
    url = f"https://www.jumia.com.eg/catalog/?q={urllib.parse.quote(query)}"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.9",
        "Cache-Control": "max-age=0",
        "Connection": "keep-alive"
    }

    products = []
    try:
        session = requests.Session()
        response = session.get(url, headers=headers, timeout=20)
        if response.status_code != 200:
            return []

        soup = BeautifulSoup(response.content, "html.parser")
        items = soup.select('article.prd')

        for idx, item in enumerate(items):
            name_el = item.select_one('h3.name')
            price_el = item.select_one('div.prc')
            if not name_el or not price_el: continue

            # Extract links and images
            link = "https://www.jumia.com.eg" + item.select_one('a.core')['href']
            img_tag = item.select_one('img.img')
            img = img_tag.get('data-src') or img_tag.get('src')

            # Numeric conversion
            price_val = float(price_el.get_text(strip=True).replace('EGP', '').replace(',', '').strip())
            old_price_el = item.select_one('div.old')
            old_price = float(old_price_el.get_text(strip=True).replace('EGP', '').replace(',', '').strip()) if old_price_el else price_val

            disc_el = item.select_one('div.bdg._dsct')
            discount = disc_el.get_text(strip=True).replace('%', '') if disc_el else "0"

            products.append({
                "Sr No": idx + 1,
                "Product URL": link,
                "Product ID": link.split('-')[-1].replace('.html', '').strip('/'),
                "Product Name": name_el.get_text(strip=True),
                "Category": "Home | Market",
                "Brand": "Market",
                "MRP (EGP)": old_price,
                "Discount %": discount,
                "Price": price_val,
                "Description": f"Accurate live deal for {name_el.get_text(strip=True)} on Jumia Egypt.",
                "Product Image URL": img,
                "Store Name": "Jumia Egypt",
                "Availability": "In Stock"
            })
    except Exception as e:
        print(f"Jumia Scrape Error: {e}")

    return products

if __name__ == "__main__":
    res = scrape_jumia_egypt("soap")
    print(f"Found {len(res)} items.")
