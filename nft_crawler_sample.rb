require 'uri'
require 'net/http'
require 'csv'
require 'json'

## 使用 mintyscore 的 api ( 透過 Chrome Network Tool 取得 API source 來源 )
uri = URI('https://api.mintyscore.com/api/v1/nfts/projects?desc=true&chain=all&status=upcoming&sort_by=minty_score&include_hidden=false')

res = Net::HTTP.get_response(uri)
body = JSON.parse(res.body)

## 以當下時間當作文件名稱
doc_name = Time.now.strftime('%Y-%m-%d %H:%M NFT List')

## 將取得的資料放入 CSV
CSV.open("#{doc_name}.csv", "w") do |csv|

  csv << [
    "項目名稱",
    "描述",
    "DC 群連結",
    "DC 群人數",
    "OpenSea 連結",
    "圖片連結",
    "價格資訊",
    "開賣時間",
    "狀態",
    "供應資訊",
    "Twitter 追蹤人數",
    "Twitter 連結",
    "網站連結",
    "評分"
  ]

  body["result"].each do |item|
    csv << [
      item["name"],
      item["description"],
      item["discord_link"],
      item["discord_member_count"],
      item["opensea_link"],
      item["picture_link"],
      item["price_info"],
      item["sale_date"],
      item["status"],
      item["supply_info"],
      item["twitter_follower_count"],
      item["twitter_link"],
      item["website_link"],
      item["minty_score"]
    ]
  end
end

