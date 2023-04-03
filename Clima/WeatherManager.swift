import Foundation

protocol WeatherManagerDelegate{
    func didUpdateWeather(weather: WeatherModel)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=028cf6b00365d3ff267d93c6220a7ade&units=metric&"
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(lat: Double, lon: Double){
        let urlString = "\(weatherURL)lat=\(lat)&lon=\(lon)"
        performRequest(urlString: urlString)
    }
    
    var delegate: WeatherManagerDelegate?
    
    func performRequest(urlString : String){
        // 1) create URl
        if let url = URL(string: urlString) {
            // 2) create URLsession
            let session = URLSession(configuration: .default)
            // 3) Give task to session
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    if let safeWeather = parseJSON(weatherData: safeData){
                        self.delegate?.didUpdateWeather(weather:safeWeather)
                    }
                }
            }
            // 4) Start Session
            task.resume()
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temperature = decodedData.main.temp
            
            return WeatherModel(id: id, name: name, temp: temperature)
        } catch{
            print(error)
            return nil
        }
    }
    
    
}
