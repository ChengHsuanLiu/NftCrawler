
## 前面參考 Google Ruby 標準文件

require "google/apis/calendar_v3"
require "googleauth"
require "googleauth/stores/file_token_store"
require "date"
require "fileutils"

OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
APPLICATION_NAME = "Google Calendar API Ruby Quickstart".freeze
CREDENTIALS_PATH = "credentials.json".freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = "token.yaml".freeze
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY


## Authorize - 必讀
## 這邊是採用 Google Service Account 去當成驗證
## 這樣才不用透過 Auth 認證 ( 要透過跳出一個 Google 登入那種 )

## 原理是 Google Service Account 有個 Calendar
## 然後透過 CLI 把這個 Calendar 加入我們自己的 Google Account 成為其中的 owner
## 然後 Google Service Account 再透過 api 加入事件，我們的帳號就也看得到
## 然後因為我們自己也是 owner，所以可以改隱私權限變成公開或分享給別人


## Google Doc Authorize
def authorize
  client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
  token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
  authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
  user_id = "default"
  credentials = authorizer.get_credentials user_id
  if credentials.nil?
    url = authorizer.get_authorization_url base_url: OOB_URI
    puts "Open the following URL in the browser and enter the " \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end


## 使用 Service Acccount 的 Credentials
## 要去 Google Developer Console 申請服務跟開通 Service Account 取得 Credentials

scopes =  ['https://www.googleapis.com/auth/calendar']
authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: File.open('credentials.json'),
  scope: scopes)
authorizer.fetch_access_token!

service = Google::Apis::CalendarV3::CalendarService.new
service.authorization = authorizer

## 使用 Service Acccount 的 Credentials 結束



## 必做動作 - 只需做一次
## 把我們的 Google Account 加入變成 Service Account Calendar 的其中一個 owner
## 把底下 value 的 email 換成你的 Google Email

# rule = Google::Apis::CalendarV3::AclRule.new(
#   scope: {
#     type: 'user',
#     value: 'chenghsuango@gmail.com',
#   },
#   role: 'owner'
# )
# result = service.insert_acl('primary', rule)
# print result.id



## 新增 Calendar Event to Calendar

calendar_id = 'primary'
event = Google::Apis::CalendarV3::Event.new({

        start: Google::Apis::CalendarV3::EventDateTime.new(date: today + 1),
        end: Google::Apis::CalendarV3::EventDateTime.new(date: today + 2),
      summary: 'New event!'

  })
service.insert_event(calendar_id, event)



## 取得 Calendar Event 的清單
response = service.list_events(calendar_id,
                               max_results: 10,
                               single_events: true,
                               order_by: 'startTime',
                               time_min: Time.now.iso8601)
