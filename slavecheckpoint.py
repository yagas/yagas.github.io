#coding=utf-8

"""
数据库同步状态侦测
MySQL数据库同步复制状态监测脚本。可配合Linux下的crond进行定时监测。如果同步
状态异常，侧使用邮件通知管理员，并将造成同步中断的错误信息也包含到邮件当中，管
理员可即时通过错误信息直接定位异常。

实例：
python MySQLStat.py --defaults-file=/etc/slave.cnf --to=xxxx@abc.com

===FILE:slave.cnf===========
[config]
smtp_host=smtp.163.com
from=消息中心<xxx@162.com>
host=localhost
"""

import mysql.connector
from mysql.connector import errorcode
import telnetlib
import smtplib
from email.mime.text import MIMEText
import optparse
from ConfigParser import ConfigParser
import os,time

class SlaveStatu:
    __instance__ = None
    __error__ = []

    def __init__(self,*args,**kwargs):
        self.__config__ = {
            "host":"localhsot",
            "user":"root",
            "password":"",
            "port":3306,
            "smtp_host":"localhost",
            "smtp_user":"",
            "smtp_password":"",
            "from":"admin@localhost",
            "to":""
        }

        #优先读取设置文件中的值
        if not kwargs["defaults_file"] is None:
            defaults_file = self.__read_defaults_file__( kwargs["defaults_file"] )
            del kwargs["defaults_file"]

        #使用参数的设置去覆盖设置文件的值
        for key,val in kwargs.items():
            if not val is None and len(val) > 0:
                self.__config__[key] = val

    def __configParseMySQL__(self):
        """
        提取数据库的设置
        :return: dict
        """
        return {
            "host"     : self.__config__["host"],
            "port"     : self.__config__["port"],
            "user"     : self.__config__["user"],
            "password" : self.__config__["password"]
        }

    def __configParseSMTP__(self):
        """
        提取SMTP邮件设置
        :return: dict
        """
        return {
            "smtp_host": self.__config__["smtp_host"],
            "smtp_user": self.__config__["smtp_user"],
            "smtp_password": self.__config__["smtp_password"],
            "from": self.__config__["from"],
            "to": self.__config__["to"]
        }

    def __read_defaults_file__( self, filePath ):
        """
        加载设置文件设置的值
        :param filePath: 设置文件路径
        :return:
        """
        section = "config"
        if os.path.exists( filePath ):
            cnf = ConfigParser()
            cnf.read( filePath )
            options = cnf.options( section )

            for key in options:
                self.__config__[key] = cnf.get( section, key )


    def telnet( self, host, port, timeout=5 ):
        """
        测试服务器地址和端口是否畅通
        :param host: 服务器地址
        :param port: 服务器端口
        :param timeout: 测试超时时间
        :return: Boolean
        """
        try:
            tel = telnetlib.Telnet( host, port, timeout )
            tel.close()
            return True
        except:
            return False

    def connect(self):
        """
        创建数据库链接
        """
        try:
            config = self.__configParseMySQL__()
            if self.telnet( config["host"],config["port"]):
                self.__instance__ = mysql.connector.connect( **config )
                return True
            else:
                raise Exception("unable connect")
        except:
            self.__error__.append( "无法连接服务器主机: {host}:{port}".format( host=config[
                    "host"], port=config["port"]) )
            return False

    def isSlave(self):
        """
        数据库同步是否正常
        :return: None同步未开启,False同步中断,True同步正常
        """
        cur = self.__instance__.cursor(dictionary=True)
        cur.execute("SHOW SLAVE STATUS")
        result = cur.fetchone()
        cur.close()

        if result:
            if result["Slave_SQL_Running"] == "Yes" and result["Slave_IO_Running"] == "Yes":
                return True
            else:
                if result["Slave_SQL_Running"] == "No":
                    self.__error__.append( result["Last_SQL_Error"] )
                else:
                    self.__error__.append( result["Last_IO_Error"] )
                return False

    def get_last_error(self):
        """
        获取第一个错误信息
        :return: String
        """
        if self.__error__:
            return self.__error__.pop(0)

    def notify(self,title,message):
        """
        发送消息提醒
        :param title: 消息的标题
        :param message: 消息的内容
        :return:
        """
        msg    = [title,message]
        pool   = []
        notify = notify_email( self.__configParseSMTP__() )
        pool.append( notify )

        for item in pool:
            item.ring( msg )

    def close(self):
        """
        关闭数据库链接
        """
        if self.__instance__:
            self.__instance__.close()

class notify_email(object):
    def __init__(self,config):
        self.config = config

    def ring(self, message=[]):
        subject = message.pop(0)
        messageBody = "".join( "", message )
        mailList = self.config["to"].split(";")
        datetime = time.strftime("%Y-%m-%d %H:%M:%S")
        for to in mailList:
            body = """
            <p>管理员<strong>{admin}</strong>，你好:</p>
            <p style="text-indent:2em;">收到这封邮件说明你的数据库同步出现异常，请您及时进行处理。</p>
            <p>异常信息：<br />{body}</p>
            <p style="text-align:right;">{date}</p>
            """.format( admin=to, body=messageBody, date=datetime )

            msg            = MIMEText( body, "html", "utf-8" )
            msg["From"]    = self.config["from"]
            msg["To"]      = to
            msg["Subject"] = subject
            smtp           = smtplib.SMTP()

            smtp.connect( self.config["smtp_host"] )
            if self.config.has_key("smtp_user"):
                smtp.login( self.config["smtp_user"], self.config["smtp_password"] )
            smtp.sendmail( self.config["from"], to, msg.as_string() )
            smtp.quit()

if __name__ == "__main__":
    #命令行参数列表
    usage = """usage: MySQLStat [options]"""

    opt = optparse.OptionParser(usage=usage)
    opt.add_option("-H","--host",dest="host",help="MySQL host (default: localhost)")
    opt.add_option("-u","--user",dest="user",help="MySQL user")
    opt.add_option("-p","--password",dest="password",help="MySQL password")
    opt.add_option("-P","--port",dest="port",help="MySQL port (default: 3306)")
    opt.add_option("","--smtp_host",dest="smtp_host",help="SMTP host (default: localhost)")
    opt.add_option("","--smtp_user",dest="smtp_user",help="SMTP user")
    opt.add_option("","--smtp_password",dest="smtp_password",help="SMTP password")
    opt.add_option("","--from",dest="from",help="Email from")
    opt.add_option("","--to",dest="to",help="Email to")
    opt.add_option("","--defaults-file",dest="defaults_file",help="config file path")
    (options,args) = opt.parse_args()

    options = options.__dict__
    Statu = SlaveStatu( **options )
    subject = "服务中心异常信息提醒"
    if Statu.connect() is False or Statu.isSlave() is False:
        Statu.notify( subject, Statu.get_last_error() )
    Statu.close()
