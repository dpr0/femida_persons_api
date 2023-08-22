# frozen_string_literal: true

class Api::Persons::SearchController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_request

  api :POST, '/search?last_name=:str&first_name=:str&middle_name=:str&birthdate=:str&birthdate_year=:str&phone=:str', 'Поиск по ФИО/Др/Год рождения/Тел'
  def create
    handler do
      prms = {}
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
    data = if prms.present?
      Person
        .eager_load(:base)
        .select(%i[ID FirstName LastName MiddleName Telephone Car Passport DayBirth MonthBirth YearBirth SNILS INN Information Base Base_Schemes.Schema])
        .where(prms)
    else
      []
    end
    errors = []
    errors << { code: :wrong_params, message: 'wrong parameters' } if prms.blank?
    { count: data.size, errors: errors, data: data }
  end

  def person_params
    params.permit(%i[last_name first_name middle_name birthdate birthdate_year phone city street building apartment])
  end
end
