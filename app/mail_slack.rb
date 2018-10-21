require 'net/imap'
require 'kconv'
require 'mail'
require 'date'

class SlackMailNotification

  IMAP_HOST = ENV["IMAP_HOST"].freeze
  IMAP_PORT = ENV["IMAP_PORT"].freeze
  IMAP_USESSL = ENV["IMAP_USESSL"].freeze
  IMAP_USER = ENV["IMAP_USER"].freeze
  IMAP_USER_PASSWD = ENV["IMAP_USER_PASSWD"].freeze

  class << self
    def login_imap
      # imapに接続
      imap = Net::IMAP.new(IMAP_HOST,IMAP_PORT,IMAP_USESSL)
      imap.login(IMAP_USER,IMAP_USER_PASSWD)
      return imap
    end
    
    def get_imap_mail
      imap = login_imap

      #件名
      subject_attr_name = 'BODY[HEADER.FIELDS (SUBJECT)]'

      #未読メールの確認
      search_criterias = [
        'UNSEEN',
        'SINCE', (Date.today - 1).strftime("%d-%b-%Y")
      ]

      # デバック
      print_debug(imap)

      mail_messages = []

      imap.select('INBOX') # 対象のメールボックスを選択

      i = 0
      imap.search(search_criterias).each do |msg_id|
         # 未読メールの件名を取得
        msg = imap.fetch(msg_id, [subject_attr_name]).first
        subject = msg.attr[subject_attr_name].toutf8.strip

      #ids = imap.search(['ALL']) # 全てのメールを取得
        imap.fetch(msg_id, "RFC822").each do |mail|

          m = Mail.new(mail.attr["RFC822"])
          # multipartなメールかチェック
          if m.multipart?
            # plantextなメールかチェック
            if m.text_part
              body = m.text_part.decoded
              mail_messages[i] = subject,body

            # htmlなメールかチェック
            elsif m.html_part
              body = m.html_part.decoded
              mail_messages[i] = subject,body
            end
          else
              body = m.body
              mail_messages[i] = subject,body
          end
        i += 1
        print_debug(i)

        end
      end
      return mail_messages
    end

    # デバック用通知
    def print_debug(body)
      imap = login_imap
      time = DateTime.now
      date_time = time.strftime("[%Y/%m/%d %H:%M:%S]")
      puts "#{date_time} message: #{body}"
    end
  end
end

# ===========================================
# 実行
# ===========================================
puts SlackMailNotification.get_imap_mail
