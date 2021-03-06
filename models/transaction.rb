#Codeclan Ruby Project
#Rex - Spending Tracker
# Transaction model classes

require_relative('../db/sql_runner')
require('pry')

class Transaction

  attr_reader :tag_id_int, :merchant_id_int, :amount_num, :trans_date, :id


  def initialize(options)
    @id = options['id'].to_i
    @tag_id_int = options['tag_id_int'].to_i
    @merchant_id_int = options['merchant_id_int'].to_i
    @amount_num= options['amount_num']
    @trans_date = options['trans_date']
  end

  def save
    sql = "INSERT INTO transactions(
    tag_id_int,
    merchant_id_int,
    amount_num,
    trans_date
    ) VALUES (
      $1,$2,$3,$4
      ) RETURNING *"
      values = [@tag_id_int,@merchant_id_int,@amount_num,@trans_date]
      transaction_obj = SqlRunner.run(sql,values)
      @id = transaction_obj.first['id'].to_i

    end

    def update() # Again with updating issue

      sql = "UPDATE transactions SET
      (
        tag_id_int,
        merchant_id_int,
        amount_num,
        trans_date,
        id
      )
      =
      (
        $1,$2,$3,$4,$5
      )
      WHERE id = $5"
      values = [@tag_id_int,@merchant_id_int,@amount_num,@trans_date,@id]
      SqlRunner.run( sql, values )
    end

    def self.all()
      sql = "SELECT * FROM transactions"
      values = []
      transactions = SqlRunner.run(sql, values)
      result = transactions.map { |transaction| Transaction.new( transaction ) }
      return result
    end

    def self.delete(id)
      sql = "DELETE FROM transactions WHERE id = $1"
      values = [id]
      SqlRunner.run(sql, values)
      return "Removed"
    end

    def self.delete_all()
      sql = "DELETE FROM transactions"
      values = []
      SqlRunner.run(sql, values)
    end

    def self.find(id)
      sql = "SELECT * FROM transactions WHERE id = $1"
      values = [id]
      results = SqlRunner.run(sql,values)
      transaction_hash = results.first
      transaction = Transaction.new(transaction_hash)
      return transaction
    end

    def merchant
      sql = "SELECT * FROM merchants WHERE id = $1"
      values = [@merchant_id_int]
      result_hash = SqlRunner.run(sql,values).first
      merchant = Merchant.new(result_hash)
      return merchant
    end

    def tag
      sql = "SELECT * FROM tags WHERE id = $1"
      values = [@tag_id_int]
      result_hash = SqlRunner.run(sql,values).first
      tag = Tag.new(result_hash)
      return tag
    end

    def self.sum
      all_transaction = Transaction.all()
      sum = 0.00
      for transaction in all_transaction
        sum += transaction.amount_num.to_f
      end
      return "%.2f" % sum
    end

    def self.in_order(column = 'trans_date',order = 'ASC')
      transactions = Transaction.all()
      case column
      when 'amount_num'
        if order == 'ASC'
          sorted = transactions.sort_by{|transaction| transaction.amount_num.to_i}
        else
         sorted = transactions.sort_by{|transaction| transaction.amount_num.to_i}.reverse
       end

      when 'trans_date'
        if order == 'ASC'
        sorted = transactions.sort_by{|transaction| transaction.trans_date}
      else
        sorted = transactions.sort_by{|transaction| transaction.trans_date}.reverse
      end
      when 'merchant_name_str'
          if order == 'ASC'
        sorted = transactions.sort_by{|transaction| transaction.merchant.merchant_name_str}
      else
        sorted = transactions.sort_by{|transaction| transaction.merchant.merchant_name_str}.reverse
      end
      when 'tag_name_str'
        if order == 'ASC'
        sorted = transactions.sort_by{|transaction| transaction.tag.tag_name_str}
      else
        sorted = transactions.sort_by{|transaction| transaction.tag.tag_name_str}.reverse
      end
      when nil
      sorted = transactions
      end
      return sorted
    end


  end #class end
