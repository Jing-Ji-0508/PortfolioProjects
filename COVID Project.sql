with PopvsVac as
(
select
dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as FLOAT)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as Rate
from PopvsVac


-- temp table
drop table if exists PercentPopulationVaccinated
create table if not exists PercentPopulationVaccinated(
		Continent varchar(255),
		Location varchar(255),
		Date datetime,
		Population numeric,
		New_vaccinations numeric,
		RollingPeopleVaccinated numeric

);
insert into PercentPopulationVaccinated
select
dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as FLOAT)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as Rate
from PercentPopulationVaccinated


-- creating View to store data for later visualizations

create View PercentPopulationVaccinated as
select
dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as FLOAT)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
 
