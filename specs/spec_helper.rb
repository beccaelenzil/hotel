# spec_helper.rb

# to do: figure out Rake

# Add simplecov
require "minitest"
require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use!
Minitest::Reporters::SpecReporter.new

require_relative "../lib/hotel.rb"

# initialize a hotel system
describe "HotelSystem" do
  it "should have access to an array of room numbers" do
    #act
    marriott = HotelSystem.new()

    #assert
    expect(marriott.room_numbers).must_be_instance_of Array
    expect(marriott.date_reservation_hash.size).must_equal 0
    expect(marriott.date_reservation_hash.size).must_equal 0
    expect(marriott.date_block_hash.size).must_equal 0
    expect(marriott.blocks_hash.size).must_equal 0
  end

  it "update: the available rooms, id_reservation_hash, and date_reservation_hash -- argument errors" do
    #arrange
    start_year = 2019
    start_month = 5
    start_day = 31
    end_year = 2019
    end_month = 6
    end_day = 3
    cost = 200
    discount = 0
    rooms = [18, 19, 20]

    #act
    marriott = HotelSystem.new()

    # 3 reservations
    for i in 1..3 do
      marriott.make_reservation(start_year, start_month, start_day, end_year, end_month, end_day, rooms[i-1], cost, discount)
    end

    #assert
    expect(marriott.get_available_rooms(start_year, start_month, start_day,end_year, end_month, end_day)).must_equal (1..17).to_a
    expect(marriott.id_reservation_hash["18067"]).must_be_instance_of Array
    expect(marriott.date_reservation_hash[Date.new(2019,5,31)]).must_be_instance_of Array

    # valid date range
    expect {marriott.make_reservation(start_year, start_month, start_day, end_year,end_month, end_day, 20, cost, discount)}.must_raise ArgumentError

    # only book available rooms
    expect {marriott.make_reservation(start_year, start_month, start_day, start_year, start_month-1, start_day, 18, cost, discount)}.must_raise ArgumentError
  end

  it "update: the available rooms, id_reservation_hash, and date_reservation_hash, blocks_hash, date_blocks, hash -- argument errors" do
    #arrange
    start_year = 2019
    start_month = 5
    start_day = 31
    end_year = 2019
    end_month = 6
    end_day = 3
    cost = 200
    discount = 0
    rooms = [18, 19, 20]

    #act
    marriott = HotelSystem.new()

    # 3 reservations
    for i in 1..3 do
      marriott.make_reservation(start_year, start_month, start_day, end_year, end_month, end_day, rooms[i-1], cost, discount)
    end

    # 3 blocks
    marriott.create_block(start_year, start_month, start_day, end_year, end_month, end_day, [1, 2, 3, 4], 200, 0.15)
    marriott.create_block(start_year, start_month, start_day, end_year, end_month, end_day, [5, 6, 7, 8], 200, 0.15)
    marriott.create_block(end_year, end_month, end_day, end_year+2, end_month+2, end_day+2, [5, 6], 200, 0.15)
    marriott.reserve_blocked_room(318052, 5)


    #assert
    # can't reserve room in a block
    expect {marriott.make_reservation(start_year, start_month, start_day, end_year,end_month, end_day, 5, cost, discount)}.must_raise ArgumentError

    # can't create block for room that's already reserved
    expect {marriott.create_block(start_year, start_month, start_day, end_year, end_month, end_day, [18,19], 200, 0.15)}.must_raise ArgumentError

    # can't create another block with rooms in another block on the same dates
    expect {marriott.create_block(start_year, start_month, start_day, end_year, end_month, end_day, [5, 6], 200, 0.15)}.must_raise ArgumentError

    # room not in block
    expect {marriott.reserve_blocked_room(318052, 1)}.must_raise ArgumentError

    # date_reservation_hash must include room reserved
    expect(marriott.date_reservation_hash[Date.new(start_year, start_month, start_day)]).must_include 5

    # rooms not reserved or not included in block
    expect(marriott.get_available_rooms(start_year, start_month, start_day,end_year, end_month, end_day)).must_equal 9..17.to_a
  end
end
