require 'uri'
require 'net/http'
require 'csv'
require 'json'
require 'time'

## 使用 mintyscore 的 api ( 透過 Chrome Network Tool 取得 API source 來源 )
uri = URI('https://api.mintyscore.com/api/v1/nfts/projects?desc=true&chain=all&status=upcoming&sort_by=minty_score&include_hidden=false')

res = Net::HTTP.get_response(uri)
body = JSON.parse(res.body)

## 以當下時間當作文件名稱
doc_name = Time.now.strftime('%Y-%m-%d %H:%M NFT Calendar Data')

## 將取得的資料放入 CSV
CSV.open("#{doc_name}.csv", "w") do |csv|

  csv << [
    "Subject",
    "Start Date",
    "Start Time",
    "End Date",
    "End Time",
    "All Day Event",
    "Description",
    "Location"
  ]

  body["result"].each do |item|


    ## 如果有開賣資料 而且 評分大於 70 才放入資料
    if item["sale_date"] != "" && item["minty_score"] > 70

      sale_date_start_time = Time.parse(item["sale_date"]) + 28800  ## 開賣時間加 8 小時當開始時間
      sale_date_end_time = Time.parse(item["sale_date"]) + 28800 + 3600 ## 開賣時間加 8 小時，再加 1 小時當結束時間

      ## 將開始與結束時間拆成 Google Calendar 要匯入的格式
      start_date = sale_date_start_time.strftime('%Y/%m/%d')
      start_time = sale_date_start_time.strftime('%H:%M')
      end_date = sale_date_end_time.strftime('%Y/%m/%d')
      end_time = sale_date_end_time.strftime('%H:%M')

      ## Google Calendar 事件名稱
      item_subject = "#{item["name"]} - NFT 開賣"

      ## 將一些附加資料放到事件的敘述中
      item_description = "
        #{item["description"]}

        Score: #{item["minty_score"]}
        Price: #{item["price_info"]}
        Website: #{item["website_link"]}

        Status: #{item["status"]}
        Supply Number: #{item["supply_info"]}


        Discord Link:  #{item["discord_link"]}
        Discord Member Count: #{item["discord_member_count"]}
        OpenSea Link: #{item["opensea_link"]}
        Twitter Link: #{item["twitter_link"]}
        Twitter Followers: #{item["twitter_follower_count"]}
        Picture Link: #{item["picture_link"]}
      "

      ## 插入 CSV
      csv << [
        item_subject,
        start_date,
        start_time,
        end_date,
        end_time,
        "",
        item_description,
        ""
      ]
    end
  end
end

