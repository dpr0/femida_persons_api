# frozen_string_literal: true

class Api::Persons::SearchController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_request

  api :POST, '/search {last_name: "", first_name: "", middle_name: "", birthdate: "", birthdate_year: "", phone: "", grn: ""', 'Поиск по ФИО/Др/Год рождения/Тел'
  def create
    handler do
      prms = {}
      prms[:Car] = person_params[:grn].upcase if person_params[:grn].present?
      prms[:INN] = person_params[:inn].upcase if person_params[:inn].present?
      prms[:LastName] = person_params[:last_name].upcase if person_params[:last_name].present?
      prms[:FirstName] = person_params[:first_name].upcase if person_params[:first_name].present?
      prms[:MiddleName] = person_params[:middle_name].upcase if person_params[:middle_name].present?
      if person_params[:birthdate].present?
        date = person_params[:birthdate].to_date
        prms[:DayBirth] = date.day
        prms[:MonthBirth] = date.month
        prms[:YearBirth] = date.year
      end
      prms[:YearBirth] = person_params[:birthdate_year] if person_params[:birthdate].blank? && person_params[:birthdate_year].present?
      prms[:Telephone] = person_params[:phone].last(10) if person_params[:phone].present?
      prms[:limit] = person_params[:limit] if person_params[:limit].present?
      prms[:offset] = person_params[:offset] if person_params[:offset].present?
      prms
    end
  end

  api :GET, '/search/by_fio?last_name=:str&first_name=:str&middle_name=:str&birthdate=:str', 'Поиск по ФИО+Др (Ф И - обязательные, О Др - необязательные)'
  def by_fio
    handler do
      prms = { LastName: "#{person_params[:last_name].upcase}", FirstName: person_params[:first_name].upcase }
      prms[:MiddleName] = person_params[:middle_name].upcase if person_params[:middle_name].present?
      if person_params[:birthdate].present?
        date = person_params[:birthdate].to_date
        prms[:DayBirth] = date.day
        prms[:MonthBirth] = date.month
        prms[:YearBirth] = date.year
      end
      prms
    end
  end

  api :GET, '/search/by_phone?phone=:str', 'Поиск по телефону'
  def by_phone
    handler do
      prms = {}
      prms[:Telephone] = person_params[:phone].last(10) if person_params[:phone].present?
      prms
    end
  end

  api :GET, '/search/by_grnz?grn=:str', 'Поиск по ГРН'
  def by_grn
    handler do
      prms = {}
      prms[:Car] = person_params[:grn].upcase if person_params[:grn].present?
      prms
    end
  end

  api :GET, '/search/by_address?city=:str&street=:str&building=:str&apartment=:str', 'Поиск по адресу (Город/Улица/Дома/Квартира - все необязательные поля)'
  def by_address
    handler do
      prms = { city: person_params[:city], street: person_params[:street] }
      prms[:building] = person_params[:building] if person_params[:building].present?
      prms[:apartment] = person_params[:apartment] if person_params[:apartment].present?
      prms
    end
  end

  private

  def handler
    with_error_handling { search yield }
  end

  def search(prms)
    grn = prms.delete(:Car)
    limit = prms.delete(:limit)
    offset = prms.delete(:offset)
    if prms.present? || (grn && grn.size > 4)
      scope = Person.eager_load(:base)
        .select(%i[FirstName LastName MiddleName Telephone Car Passport DayBirth MonthBirth YearBirth SNILS INN Information Base Base_Schemes.Schema])
        .where(prms)
      scope = scope.where('"persons_with_fts"."Car" LIKE ?', "%#{grn}%") if grn
      count = scope.count
      scope = scope.limit(limit) if limit
      scope = scope.offset(offset) if offset
      data = scope.all.map do |z|
        z = z.attributes
        hash = {}
        passport = z.delete('Passport')
        schema = parse_json(z.delete('Schema'))
        inform = parse_json(z.delete('Information'))
        (0..schema.size-1).each { |i| hash[schema[i]] = inform[i] if inform[i].present? }
        dt = parse_date([z.delete('DayBirth'), z.delete('MonthBirth'), z.delete('YearBirth')])
        dt2 = parse_date([hash.delete('ДАТА РОЖДЕНИЯ'), hash.delete('Месяц'), hash.delete('Год')])
        dt3 = parse_date([hash.delete('Дата выдачи'), hash.delete('Мес выдачи'), hash.delete('Год выдачи')])
        pasp = [hash.delete('Серия паспорта'), hash.delete('Номер паспорта')].compact.join
        name = [z.delete('LastName'), z.delete('FirstName'), z.delete('MiddleName')].compact.join(' ')
        hash['ИМЯ']           = name                  if name.present?
        hash['ИСТОЧНИК']      = z.delete('Base')
        hash['ПАСПОРТ']       = passport if passport.present?
        hash['ПАСПОРТ_']      = pasp if pasp.present?
        hash['ПАСПОРТ_ВЫДАН'] = dt3 if dt3
        hash['СНИЛС']         = z.delete('SNILS')     if z['SNILS'].present?
        hash['ИНН']           = z.delete('INN')       if z['INN'].present?
        hash['ТЕЛЕФОН']       = z.delete('Telephone') if z['Telephone'].present?
        hash['ДАТА РОЖДЕНИЯ'] = dt                    if dt.present?
        hash['ДАТА РОЖДЕНИЯ'] ||= dt2                 if dt2.present?
        z.each { |key, value| hash[key] = value if value.present? }
        hash
      end
      { count: count, errors: [], data: data }
    else
      { count: 0, errors: [{ code: :wrong_params, message: 'wrong parameters' } ], data: [] }
    end
  end

  def parse_json(str)
    JSON.parse(str.delete("\t"))['D']
  rescue
    {}
  end

  def parse_date(array)
    dr = array.compact.join('.')
    dr.to_date&.strftime('%d.%m.%Y') if dr.present?
  rescue
  end

  def person_params
    @params ||= params.permit(%i[inn grn last_name first_name middle_name birthdate birthdate_year phone city street building apartment limit offset])
  end
end
